#lang racket
(require "typed/fit.rkt"
         json
         db
         plot
         threading
         racket/generator
         racket/serialize
         racket/date)
;; Data mangeling
(define (transpose data)
  (vector->list (apply vector-map list data)))

(define (fit-data data [n 2])
  (apply fit
         (append (transpose data) (list n))))

;; ** Analysis
(define (focus-x data-set)
  (define-values (c b a) (vector->values (fit-data data-set)))
  (/ (* -1 b)
     (* 2 a)))

(define (dimensions window)
  (let ([first-coord (sequence-ref window 0)]
        [last-coord (sequence-ref window (- (sequence-length window) 1))])
    (values (vector-ref first-coord 0) (vector*-ref first-coord 1)
            (vector-ref last-coord 0) (vector*-ref last-coord 1))))

(define number-of-coins (make-parameter 1))
(define (peak? window)
  (define-values (x0 y0 xn yn) (dimensions window))
  (define price-diff (abs (- yn y0)))
  (if (< price-diff (* 0.04 (number-of-coins) yn))
      #f
      (let* ([middle-of-data (+ x0
                                (/ (- xn x0)
                                   2))]
             [focus-in-the-ladder-part-of-data (<= middle-of-data  (focus-x window) xn)])
        focus-in-the-ladder-part-of-data)))
;; ** Data set
(define kraken-db (sqlite3-connect #:database
                                   "/home/kristian/projects/gekko/history/kraken_0.1.db"))
;; (define rows (query-rows kraken-db "select start,open from candles_EUR_XMR order by start asc"))
;; first test window: 1547101200
;; (with-output-to-file "first-part.data"
;;   (λ () (write (serialize rows))))
;; (define rows (deserialize (with-input-from-file "first-part.data" read)))
;; (define rows (deserialize (with-input-from-file "2019-01-01-00-06_2019-12-16-14-02.data"
;;                             read)))
(define (max-x)
  (query-value kraken-db "select max(start) from candles_EUR_XMR"))
(define (get-window #:start (start 0)
                    #:end (end (max-x))
                    #:connection (connection kraken-db))
  (query-rows connection "select start,open from candles_EUR_XMR where start > $1 and start < $2 order by start asc" start end))
;; (define slices (in-slice 10 (in-list rows)))
(define slice-size (make-parameter 10))
(define slice-rows (lambda-and~> in-list
                                 (in-slice (slice-size) _)))

(define (append-slices slices #:yield-when (yield-when (λ () #t)))
  (in-generator
   (for/fold ([data-accum '()])
             ([slice (in-sequences slices)])
     (let*-values ([(cur-data) (append data-accum slice)])
       (if (yield-when cur-data)
           (begin (yield cur-data)
                  '())
           cur-data)))))

(define last-x (lambda~> last
                         (vector-ref 0)))

(module+ export
  (define (save-as-json slices)
    (with-output-to-file "trade.json"
      (λ () (printf (jsexpr->string (for/list ([p  (append-slices slices #:yield-when peak?)])
                                      (last-x p)))))
      #:exists 'replace)))

(define (print-peaks slices)
  (for ([p (append-slices slices #:yield-when peak?)])(displayln (last-x p))))
(define (peak-stream #:start (start 0)
                     #:end (end (max-x))
                     #:connection (connection kraken-db))
  (~> (get-window #:start start #:end end #:connection connection)
      slice-rows
      (append-slices #:yield-when peak?)
      sequence->stream))
(module+ test
  (require rackunit)
  (let ([slices (peak-stream 0)])
    (check-equal? '#[1546539900 1546795500 1546813500] (for/vector ([p (stream-take slices 3)])
                                                         (last-x p)))))
