#lang racket
(require "math.rkt")
(define ((poly v) x)
  (for/sum ([c v]
            [i (in-naturals)])
    (* c (expt x i))))

;; Polynomial/Multiple regression
;; Source: https://rosettacode.org/wiki/Polynomial_regression#Racket
(define (fit x y n)
  (define Y (->col-matrix y))
  (define V (vandermonde-matrix x (+ n 1)))
  (define VT (matrix-transpose V))
  (matrix->vector (matrix-solve (matrix* VT V) (matrix* VT Y))))

(module+ test
  (require "test.rkt")
  (module+ ))
