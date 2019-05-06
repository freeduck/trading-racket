#lang racket
(require crypto-trading/advicer
         crypto-trading/test
         crypto-trading/plot
         crypto-trading/math)

(define (find-advice  time-series #:step [step 600] [window-size step] #:scope [scope take] [advice #f])
  (with-handlers ([exn:fail:contract? (lambda (exn)
                                        #f)])
    (if advice
        advice
        (find-advice time-series
                     #:step step
                     (+ step window-size)
                     (get-advice (scope time-series window-size))
                     #:scope scope))))

(define (remove-noise)
  (find-advice #:scope drop (test-data-source noise-start aprox-peak-after-noise)))
