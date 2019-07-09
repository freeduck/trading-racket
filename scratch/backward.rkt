#lang racket
(require "../fit.rkt"
         "../data-mangling.rkt"
         "../test.rkt"
         "../query.rkt"
         plot
         threading)

(define (find-peak-in-list data-source validate-peak-fn)
  (let-values ([(peak data-series) (for/fold ([peak #f] [old-data '()])
                                             ([bin (in-list (reverse data-source))]
                                              #:break peak)
                                     (let ([data (append bin old-data)])
                                       (values (find-peak data #:validate-fn validate-peak-fn) data)))])
    peak))

(define (within-prize-threshold? a-time-series (threshold 0.02))
  (let* ([time-series (if (list? a-time-series)
                          a-time-series
                          (sequence->list a-time-series))]
         [first-prize (first-prize-in-series time-series)]
         [last-prize (last-prize-in-series time-series)]
         [prize-delta (abs (- last-prize first-prize))])
    (if (> (* threshold
              first-prize)
           prize-delta)
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
