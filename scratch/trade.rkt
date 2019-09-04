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

  (module+ trade
    (define (trade amount prize account)
      (let ([total (* (amount) (prize))])
        (cond
          [(and (xmr? amount)
                (eur? prize)) (hash-set* account
                                         xmr (- (hash-ref account xmr)
                                                (amount))
                                         eur (+ (hash-ref account eur)
                                                total))
           (and (xmr? amount)
                (eur? prize)) (hash-set* account
                                         xmr (+ (hash-ref account xmr)
                                                (amount))
                                         eur (- (hash-ref account eur)
                                                total))])))

    (define (sell amount prize account)
      (trade amount prize account))
    (define (buy amount prize account)
      (trade prize amount account))
    (for/fold ([acc (hash eur 100
                          xmr 20)])
              ([peak peak-seq])
      (let* ([peak-data (sequence->list peak)]
             [opening-prize (vector-ref (first peak-data) 1)]
             [closing-prize (vector-ref (last peak-data) 1)]
             [diff (- closing-prize opening-prize)]
             [amount (xmr 5)]
             [prize (eur closing-prize)])
        (if (> diff 0)
            (sell amount acc)
            (buy amount acc))))))
