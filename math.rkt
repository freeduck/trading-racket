#lang racket
(require
 math)
(provide fft
         transpose
         create-fft-sample
         strip-to-power-of-two
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
(define (transpose data)
  (vector->list (apply vector-map list data)))

(define (create-fft-sample data-set)
  (list->array (strip-to-power-of-two (second (transpose data-set)))))

(define (fft data-set)
  (let* ([fft-sample (create-fft-sample data-set)]
         [freq-sample (* 60 24)] ;
         [ft (array->list (array-fft fft-sample))]
         [fft-coefficient (/ freq-sample (length ft))])
    (for/list ([bin ft]
               [i (in-naturals 1)])
      (vector(exact->inexact (* fft-coefficient i))
             (magnitude bin)))))
