#lang racket

(require "../test.rkt"
         "../fit.rkt"
         "../plot.rkt"
         threading)

(require "../peak.rkt")

(parameterize ([data-path ".."])
  (and~> (test-data-source first-trade (- second-trade-target (* 3600 3)))
         data-set->parabola
         validate-peak))
