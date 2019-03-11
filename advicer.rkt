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
         [last-data-point (last time-series)]
         [current-prize (vector-ref last-data-point 1)]
         [prize-delta (abs (- current-prize prize-last-trade))]
         [get-slope regression-analysis-linear-slope]
         [get-coeff regression-analysis-coefficient-1st-exponent]
         [eval-analysis (lambda (analysis)
                        (let* ([coeff (get-coeff analysis)]
                               [slope (get-slope analysis)]
                               [polyfun (regression-analysis-polyfun analysis)]
                               [linearfun (regression-analysis-linearfun analysis)]
                               [advice (cond [(and (> slope 0)
                                                   (> coeff 0))
                                              'sell]
                                             [(and (< slope 0)
                                                   (< coeff 0))
                                              'buy]
                                             [else #f])])
                          (if advice
                              (let* ([poly-prediction (polyfun (vector-ref last-data-point 0))]
                                    [linear-prediction (linearfun (vector-ref last-data-point 0))]
                                    [prediction-diff (abs (- poly-prediction linear-prediction))])
                                (if (> prediction-diff 2)
                                    (trade-advice advice analysis)
                                    #f))
                              #f)))]
         [wait (lambda () 'wait)])
    (if (< prize-delta threshold)
        #f
        (cond [(find-peak time-series) => eval-analysis]
              [else #f]))))