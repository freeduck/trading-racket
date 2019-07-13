#lang racket
(require "fit.rkt")
(provide validate-peak)
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
