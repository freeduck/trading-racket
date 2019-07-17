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
  (module+ first
    (parameterize ([data-path ".."])
      (~> (test-data-source first-trade second-trade-target)
          slice-data
          (append-slices #:yield-when peak?)
          (sequence-ref 0) 
          lines
          plot))))
