#lang racket
(require crypto-trading/fit)

(provide get-advice
         (struct-out trade-advice)
         (all-from-out crypto-trading/fit))

(struct trade-advice (advice analysis)
  #:property prop:procedure (lambda (self)
                              (trade-advice-advice self)))

(define (get-advice time-series)
  (let* ([prize-last-trade (vector-ref (first time-series) 1)]
         [threshold (* 0.02 prize-last-trade)]
         [first-data-point (first time-series)]
         [last-data-point (last time-series)]
         [current-prize (vector-ref last-data-point 1)]
         [first-x (vector-ref first-data-point 0)]
         [last-x (vector-ref last-data-point 0)]
         [prize-delta (abs (- current-prize prize-last-trade))]
         [get-slope regression-analysis-linear-slope]
         [get-coeff regression-analysis-coefficient-1st-exponent]
         [eval-analysis (lambda (analysis)
                          (let* ([coeff (get-coeff analysis)]
                                 [slope (get-slope analysis)]
                                 [advice (if (and (< (regression-analysis-xmom analysis)
                                                     (vector-ref last-data-point 0)) ; extream within window
                                                  (> (abs (regression-analysis-linear-slope analysis)) 5e-05) ; Too flat
                                                  ;; (< 14400 (- last-x first-x)) ; if window bigger than three hours maby start chipping of from the beginning
                                                  #t)
                                             (cond [(and (> slope 0)
                                                         (> coeff 0))
                                                    'sell]
                                                   [(and (< slope 0)
                                                         (< coeff 0))
                                                    'buy]
                                                   [else #f])
                                             #f)])
                            (if advice
                                (trade-advice advice analysis)
                                #f)))]
         [wait (lambda () 'wait)])
    (if (< prize-delta threshold)
        #f
        (cond [(find-peak time-series) => eval-analysis]
              [else #f]))))
