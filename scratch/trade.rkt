#lang racket

(require "../peak.rkt"
         "../trade.rkt"
         threading)

(module+ test
  (require "../test.rkt"
           rackunit)
  
  (define peak-seq (~> (parameterize ([data-path ".."])
                         (select-single-ohlc-field))
                       (peaks)))
  (module+ peak-list
    (sequence->list peak-seq))

  (module+ fold-it
    (sequence-fold
     (λ (acc peak)
       (let ([diff (- (vector-ref (last peak) 1)
                     (vector-ref (first peak) 1))])
        (if (> diff 0)
            (sell (xmr 5) account)
            (buy (xmr 5) account))))))
  
  (module+ trade
    (for/fold ([acc (account (list (eur 100)
                                   (xmr 20)))])
              ([peak peak-seq])
      (let* ([peak-data (sequence->list peak)]
            [diff (- (vector-ref (last peak-data) 1)
                     (vector-ref (first peak-data) 1))])
        (if (> diff 0)
            (sell (xmr 5) account)
            (buy (xmr 5) account))))))
