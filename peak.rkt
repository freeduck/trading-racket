#lang racket
(require "fit.rkt"
         "./data-mangling.rkt"
         threading)
(provide peaks
         peak?
         first-peak
         validate-peak)

(define peaks (λ (data-set #:peak? (peak? peak?))
                (~> data-set
                    slice-data
                    (append-slices #:yield-when peak?))))
(define (first-peak data-set)
  (for/first ([part data-set]
              #:when (peak? part))
    part))
(define (validate-peak para)
  (let* ([data-set (parabola-data-set para)]
         [first-x (vector-ref (first data-set) 0)]
         [last-x (vector-ref (last data-set) 0)]
         [average (/ (+ last-x first-x)
                     2)]
         [focus-x (parabola-focus-x para)])
    (if (<= average focus-x last-x)
        para
        #f)))

(define peak? (λ-and~> data-set->parabola
                       validate-peak))
