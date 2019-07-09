#lang racket
(require "../fit.rkt"
         "../data-mangling.rkt"
         "../test.rkt"
         plot
         threading)

(define (find-peak-in-list data-source validate-peak-fn)
  (let-values ([(peak data-series) (for/fold ([peak #f] [old-data '()])
                                             ([bin (in-list (reverse data-source))]
                                              #:break peak)
                                     (let ([data (append bin old-data)])
                                       (values (find-peak data #:validate-fn validate-peak-fn) data)))])
    peak))

(define (within-prize-threshold? a-time-series)
  (let* ([time-series (if (list? a-time-series)
                          a-time-series
                          (sequence->list a-time-series))]
         [prize-last-trade (vector-ref (first time-series) 1)]
         [_ (displayln prize-last-trade)]
         [last-data-point (last time-series)]
         [current-prize (vector-ref last-data-point 1)]
         [_ (displayln current-prize)]
         [prize-delta (abs (- current-prize prize-last-trade))]
         [threshold (* 0.02 prize-last-trade)])
    (if (< prize-delta threshold)
        #f
        a-time-series)))

(define (validate-peak peak-analysis)
  (and~> peak-analysis
         within-prize-threshold?))

(parameterize ([data-path ".."])
  (and~> (test-data-source noise-start aprox-peak-after-noise)
         slice-data
         (find-peak-in-list validate-peak)
         lines
         plot))
