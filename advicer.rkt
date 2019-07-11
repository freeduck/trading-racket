#lang racket
(require crypto-trading/fit)

(provide get-advice
         good-peak
         (struct-out trade-advice)
         (all-from-out crypto-trading/fit))

(struct trade-advice (advice analysis)
  #:property prop:procedure (lambda (self)
                              (trade-advice-advice self)))
(define (extream-within-window analysis last-data-point)
  (< (regression-analysis-xmom analysis)
     (vector-ref last-data-point 0)))
(define (peak-at-end slope coeff)
  (cond [(and (> slope 0)
              (> coeff 0))
         'sell]
        [(and (< slope 0)
              (< coeff 0))
         'buy]
        [else #f]))

(define good-peak (make-parameter (lambda (analysis last-data-point)
                                    (let* ([get-slope regression-analysis-linear-slope]
                                           [get-coeff regression-analysis-coefficient-1st-exponent]
                                           [coeff (get-coeff analysis)]
                                           [slope (get-slope analysis)]
                                           [advice (if (and (extream-within-window analysis last-data-point) ; extream within window
                                                            (> (abs (regression-analysis-linear-slope analysis)) 5e-05) ; Too flat
                                                            ;; (< 14400 (- last-x first-x)) ; if window bigger than three hours maby start chipping of from the beginning
                                                            #t)
                                                       (peak-at-end slope coeff)
                                                       #f)])
                                      (if advice
                                          (trade-advice advice analysis)
                                          #f)))))

(define (get-advice time-series)
  (let* ([prize-last-trade (vector-ref (first time-series) 1)]
         [threshold (* 0.02 prize-last-trade)]
         [first-data-point (first time-series)]
         [last-data-point (last time-series)]
         [current-prize (vector-ref last-data-point 1)]
         [first-x (vector-ref first-data-point 0)]
         [last-x (vector-ref last-data-point 0)]
         [prize-delta (abs (- current-prize prize-last-trade))]
         [eval-analysis (lambda (analysis)
                          ((good-peak) analysis last-data-point))]
         [wait (lambda () 'wait)])
    (if (< prize-delta threshold)
        #f
        (cond [(find-peak time-series) => eval-analysis]
              [else #f]))))
