#lang racket
(require db
         plot
         threading
         math
         racket/generator)

;; ** Fit
(define (transpose data)
  (vector->list (apply vector-map list data)))

(define (fit x y n)
  (define Y (->col-matrix y))
  (define V (vandermonde-matrix x (+ n 1)))
  (define VT (matrix-transpose V))
  (matrix->vector (matrix-solve (matrix* VT V) (matrix* VT Y))))

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

(define (peak? window)
  (define-values (x0 y0 xn yn) (dimensions window))
  (define middle-of-data (+ x0
                            (/ (- xn x0)
                               2)))

  (define focus-in-the-ladder-part-of-data (<= middle-of-data  (focus-x rows) xn))
  (define minimum-prize-span (<= 2 (- yn y0)))
  (and focus-in-the-ladder-part-of-data
       minimum-prize-span))
;; ** Data set
(define kraken-db (sqlite3-connect #:database
                                   "/home/kristian/projects/gekko/history/kraken_0.1.db"))
(define rows (query-rows kraken-db "select start,open from candles_EUR_XMR where start < 1547101200"))

(define slices (in-slice 10 (in-list rows)))

(define (append-slices slices #:yield-when (yield-when (λ () #t)))
  (in-generator
   (for/fold ([data-accum '()])
             ([slice (in-sequences slices)])
     (let*-values ([(cur-data) (append data-accum slice)])
       (if (yield-when cur-data)
           (begin (yield cur-data)
                  '())
           cur-data)))))


