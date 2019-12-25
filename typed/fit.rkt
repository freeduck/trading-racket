#lang typed/racket
(require math)
(provide fit)
;; ** Fit
(: fit (-> (Listof Integer) (Listof Real) Integer (U (Immutable-Vectorof Real) (Mutable-Vectorof Real))))
(define (fit x y n)
  (define Y (->col-matrix y))
  (define V (vandermonde-matrix x (+ n 1)))
  (define VT (matrix-transpose V))
  (matrix->vector (matrix-solve (matrix* VT V) (matrix* VT Y))))
