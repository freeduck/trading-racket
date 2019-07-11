#lang racket

(require "../test.rkt"
         "../fit.rkt"
         threading)
(parameterize ([data-path ".."])
  (~> (test-data-source first-trade second-trade-target)
      data-set->parabola
      parabola-focal-length))
