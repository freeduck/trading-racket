#lang racket

(require "../test.rkt"
         "../fit.rkt"
         "../plot.rkt"
         threading)

(require "../peak.rkt")
(module+ test
  (define test-data (parameterize ([data-path ".."])
                      (~> (select-single-ohlc-field)
                          (peaks #:peak? peak?))))
  (module+ plot-first-peak
    (~> (sequence-ref test-data 2)
        lines
        plot))
  (module+ validate-first-peak
    (parameterize ([data-path ".."])
      ;; (define end (* 3600 3))
      (define end 0)
      (and~> (test-data-source first-trade (- second-trade-target end))
             data-set->parabola
             validate-peak))))
