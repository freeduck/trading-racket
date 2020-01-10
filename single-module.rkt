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

(define (reverse-peak? window)
  (not (~> window
           ((λ (w) (let* ([t (transpose w)]
                          [x (first t)]
                          [y (second t)])
                     (map list->vector (transpose (list (list->vector x) (list->vector (reverse y))))))))
           (take _ (min (* 60 24)
                        (length window)))
           (peak-stream _ #:peak? forward-peak?)
           stream-empty?)))

(define (forward-peak? window)
  (define-values (x0 y0 xn yn) (dimensions window))
  (define price-diff (abs (- yn y0)))
  (if (< price-diff (* 0.08 yn))
      #f
      (let* ([middle-of-data (+ x0
                                (/ (- xn x0)
                                   2))]
             [focus-in-the-ladder-part-of-data (<= middle-of-data  (focus-x window) xn)])
        focus-in-the-ladder-part-of-data)))

(define (peak? window)
  (let ([forward-period (* 60 24 5)])
    (if (> forward-period (length window))
        (forward-peak? window)
        (reverse-peak? window))))
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
  (define (save-as-json)
    (with-output-to-file "trade.json"
      (λ () (printf (jsexpr->string (for/list ([p  (peak-stream (get-window))])
                                      (last-x p)))))
      #:exists 'replace)))

(define (print-peaks slices)
  (for ([p (append-slices slices #:yield-when peak?)])(displayln (last-x p))))

(define (peak-stream window #:peak? (peak? peak?))
  (~> window
      slice-rows
      (append-slices #:yield-when peak?)
      sequence->stream))
(module+ test
  (require rackunit)
  (let ([slices (peak-stream 0)])
    (check-equal? '#[1546539900 1546795500 1546813500] (for/vector ([p (stream-take slices 3)])
                                                         (last-x p)))))
(module+ reverse
  (for/list ([p (in-stream (peak-stream (get-window #:start 1551049200
                                                    #:end 1554064200)))])
    (last-x p)))

(define number-of-coins (make-parameter 1))
;; Find previous trade where historic price is the same or lower for buy and same or higher for sell
(define (find-trade-amount trade-history trade-type current-price)
  (if (empty? trade-history)
      (number-of-coins)
      (let* ([historic-trades (reverse (takef trade-history (λ (trade)
                                                              (let ([historic-price (third trade)]
                                                                    [compare-operator (if (eq? 'buy trade-type)
                                                                                          <=
                                                                                          >=)])
                                                                (not 
                                                                 (compare-operator historic-price current-price))))))]
             [level (foldl (λ (trade acc)
                             (let ([historic-trade-type (first trade)]
                                   [historic-amount (second trade)])
                               (if (eq? 'buy historic-trade-type)
                                   (+ acc historic-amount)
                                   (- acc historic-amount)))) 0 (rest historic-trades))])
        (if (or (eq? 0 level)
                (and (eq? trade-type 'buy)
                     (> level 0))
                (and (eq? trade-type 'sell)
                     (< level 0))) 
            (number-of-coins)
            (if (eq? trade-type 'buy)
                (abs level)
                level)))))


(module+ trading-strategies
  (define (trade xmr eur peaks amount-fn)
      (for/fold ([xmr xmr]
                 [eur eur]
                 [initial-price #f]
                 [final-price 0]
                 [historic-trades '()])
                ([p peaks])
        (let*-values ([(x0 y0 xn yn) (dimensions p)]
                      [(price-diff) (- yn y0)]
                      [(initial-price) (if (eq? #f initial-price)
                                           y0
                                           initial-price)]
                      [(trade-type) (if (> price-diff 0)
                                        'sell
                                        'buy)]
                      [(amount) (amount-fn historic-trades trade-type yn)])
          (when (< eur 0)
            (displayln (string-append "No more funding" (number->string xn) (number->string xmr))))
          (when (< xmr 0)
            (displayln (string-append "No more coins" (number->string xn) (number->string  xmr))))
          (if (eq? 'sell trade-type)
              (values (- xmr amount) (+ eur (* yn amount)) initial-price yn (cons (list 'sell amount yn) historic-trades))
              (values (+ xmr amount) (- eur (* yn amount)) initial-price yn (cons (list 'buy amount yn) historic-trades))))))
  
  (module+ same-amount
    (for/fold ([xmr 30]
               [eur 2000]
               [initial-price #f]
               [final-price 0])
              ([p (in-stream (peak-stream (get-window #:start 1546297200)))])
      (let*-values ([(x0 y0 xn yn) (dimensions p)]
                    [(price-diff) (- yn y0)]
                    [(initial-price) (if (eq? #f initial-price)
                                         y0
                                         initial-price)])
        (when (< eur 0)
          (error "No more funding"))
        (when (< xmr 0)
          (error "No more coins"))
        (if (> price-diff 0)
            (begin
              (displayln "Sell")
              (values (- xmr 5) (+ eur (* yn 5)) initial-price yn))
            (begin
              (displayln "Buy")
              (values (+ xmr 5) (- eur (* yn 5)) initial-price yn))))))
  (module+ level
    (trade 20 2000 (in-stream (peak-stream (get-window #:end 1547695800))))
    ;; we are buying
    ;; (define trade-type 'buy)
    ;; (define current-price 37.63)
    ;; thesis one:
    ;; if we meet a trade of the same type we recurs
    ;; and let it eat what it can.
    ;; the list must be a iterator which can be passed.
    ;; '((buy 45.95) (sell 48.0) (sell 45.84) (sell 43.1))
    ;; (define trade-history '((buy 45.95) (sell 48.0) (sell 45.84) (sell 43.1)))
    (module+ test-data
      (define trade-type 'buy)
      (define current-price 37.63)
      (define trade-history '((buy 45.95) (sell 48.0) (sell 45.84) (sell 43.1))))
    
    


    #;(define (find-trade-amount trade-type trades)
      (for/fold ([amount 0]
                 [processed-trades '()])
                ([t trades])
        (if (not (eq? trade-type (first t)))
            (find-trade-amount )
            #t))))) ;nonsense
