#lang racket

(require "../test.rkt"
         "../fit.rkt"
         "../plot.rkt"
         threading)
(parameterize ([data-path ".."])
  (~> (test-data-source first-trade second-trade-target)
      data-set->parabola
      ((λ (para)
         (plot (parabola->plotables para))))))
