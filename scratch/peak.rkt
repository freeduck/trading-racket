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
         ((λ (p) (plot (list (points (list (vector (parabola-focus-x p)
                                                   (parabola-directrix p)))
                                     #:color '(255 0 0))
                             (points (list (vector (parabola-focus-x p)
                                                   (parabola-focus-y p)))
                                     #:color '(0 255 0))
                             (points (list (vector (parabola-focus-x p)
                                                   (parabola-vertex p))))))))))
