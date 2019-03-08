#lang racket
(require crypto-trading/fit)

(provide get-advice (struct-out trade-advice))

(struct trade-advice (advice analysis)
  #:property prop:procedure (lambda (self)
                              (trade-advice-advice self)))

(define (get-advice time-series)
  (let* ([prize-last-trade (vector-ref (first time-series) 1)]
         [threshold (* 0.002 prize-last-trade)]
         [current-prize (vector-ref (last time-series) 1)]
         [prize-delta (abs (- current-prize prize-last-trade))]
         [get-slope regression-analysis-linear-slope]
         [make-advice (lambda (analysis)
                        (trade-advice (if (> (get-slope analysis) 0)
                                          'sell
                                          'buy) analysis))]
         [wait (lambda () 'wait)])
    (if (< prize-delta threshold)
        wait
        (cond [(find-peak time-series) => make-advice]
              [else wait]))))
