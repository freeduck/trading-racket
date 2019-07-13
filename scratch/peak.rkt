#lang racket

(require "../test.rkt"
         "../fit.rkt"
         "../plot.rkt"
         threading)

(require "../peak.rkt")

(parameterize ([data-path ".."])
  ;; (define end (* 3600 3))
  (define end 0)
  (and~> (test-data-source first-trade (- second-trade-target end))
         data-set->parabola
         ((λ (p) (> (parabola-vertex p) (parabola-directrix p))))))
