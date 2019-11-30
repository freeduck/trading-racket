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
  (let*-values (([first-x first-y last-x last-y] (dimensions para))
                ([offset] (offset first-x last-x))
                ([focus-x] (parabola-focus-x para)))
    (if (and (<= offset focus-x last-x)
             (< 1.5 (abs (- last-y first-y))))
        para
        #f)))

(define peak? (λ-and~> data-set->parabola
                       validate-peak))
(define (dimensions window)
  (let ([first-coord (sequence-ref window 0)]
        [last-coord (sequence-ref window (- (sequence-length window) 1))])
    (values (vector-ref first-coord 0) (vector*-ref first-coord 1)
            (vector-ref last-coord 0) (vector*-ref last-coord 1))))

(define (offset first-x last-x)
  (+ (* 0.5 (- last-x first-x))
                            first-x))
(module+ test
  (require "test.rkt"
           rackunit
           plot)
  (define peak-seq (~> (select-single-ohlc-field)
                       (peaks)))
  (define first-peak (sequence-ref peak-seq 0))
  (let-values (([first-x first-y last-x last-y] (dimensions first-peak)))
    (display-lines (list first-x first-y last-x last-y))
    (displayln (offset first-x last-x))
    (plot (lines first-peak))))
