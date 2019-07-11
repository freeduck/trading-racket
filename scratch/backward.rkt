#lang racket
(require "../advicer.rkt"
         "../data-mangling.rkt"
         "../test.rkt"
         "../query.rkt"
         plot
         threading)

(define (find-peak-in-list data-source validate-data-fn)
  (for/fold ([peak-at '()])
            ([bin (in-list (reverse data-source))]
             #:break (regression-analysis? peak-at))
    (let ([data (append bin peak-at)])
      (and~> data
             validate-data-fn
             find-peak))))

(define (within-prize-threshold? time-series (threshold 0.02))
  (let ([numeric-threshold (* threshold (first-prize-in-series time-series))])
    (if (< (prize-delta time-series)
           numeric-threshold)
        time-series
        #f)))

(define (validate-peak peak-analysis)
  (and~> peak-analysis
         within-prize-threshold?))

(parameterize ([data-path ".."])
  (and~> (test-data-source noise-start aprox-peak-after-noise)
         slice-data
         (find-peak-in-list validate-peak)
         lines
         plot))
