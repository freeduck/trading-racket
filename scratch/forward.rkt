#lang racket
(require "../test.rkt"
         "../data-mangling.rkt"
         "../fit.rkt"
         "../peak.rkt"
         "../plot.rkt"
         threading)
(module+ test
  (require rackunit)
  (module+ main
    (displayln "Hest"))
  (module+ scratch
    (parameterize ([data-path ".."])
      (~> (test-data-source first-trade second-trade-target)
          slice-data
          append-slices
          first-peak
          lines
          plot))))
