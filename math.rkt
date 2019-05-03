#lang racket
(require
 math)
(provide strip-to-power-of-two
         complex-sort-by-magnitude
         (all-from-out math))

(define (strip-to-power-of-two l)
  (if (power-of-two? (length l))
      l
      (strip-to-power-of-two (cdr l))))

(define (complex-sort-by-magnitude a b)
  (let ((magnitude-a (sqrt (+ (expt (real-part a) 2)
                              (expt (imag-part a) 2))))
        (magnitude-b (sqrt (+ (expt (real-part b) 2)
                              (expt (imag-part b) 2)))))
    (> magnitude-a magnitude-b)))
