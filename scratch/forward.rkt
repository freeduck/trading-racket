#lang racket
(require "../test.rkt"
         "../data-mangling.rkt"
         "../fit.rkt"
         "../peak.rkt"
         "../plot.rkt"
         threading)
(module+ test
  (parameterize ([data-path ".."])
    (for/first ([part (~> (test-data-source first-trade second-trade-target)
                          slice-data
                          append-slices)]
                #:when (and~> part
                              data-set->parabola
                              validate-peak))
      (plot (lines part)))))
