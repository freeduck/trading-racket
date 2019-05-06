#lang racket
(require crypto-trading/advicer
         crypto-trading/test
         crypto-trading/plot
         crypto-trading/math)

(define (find-advice  time-series #:step [step 600] [window-size step] #:scope [scope take] #:advice [advice #f])
  (with-handlers ([exn:fail:contract? (lambda (exn)
                                        #f)])
    (begin
      (displayln advice)
      (displayln (get-advice time-series))
      (if (get-advice time-series)
          (displayln "ad")
          (displayln "no"))
      (if advice
        advice
        (find-advice time-series
                     #:step step
                     (+ step window-size)
                     #:advice (get-advice (scope time-series window-size))
                     #:scope scope)))))

(define (remove-noise)
  (find-advice #:scope drop #:step 150 (test-data-source noise-start aprox-peak-after-noise))) ;

(define (plot-noise)
  (plot-on-frame (lines (test-data-source noise-start aprox-peak-after-noise))))
