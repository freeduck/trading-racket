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
    ;; (define (trade amount prize account)
    ;;   (let ([total (* (amount) (prize))])
    ;;     (if (and (xmr? amount)
    ;;              (eur? prize))
    ;;         (hash-set* account
    ;;                                      xmr (- (hash-ref account xmr)
    ;;                                             (amount))
    ;;                                      eur (+ (hash-ref account eur)
    ;;                                             total))
    ;;         (hash-set* account
    ;;                                      xmr (+ (hash-ref account xmr)
    ;;                                             (amount))
    ;;                                      eur (- (hash-ref account eur)
    ;;                                             total)))))

    ;; (define (sell amount prize account)
    ;;   (trade amount prize account))
    ;; (define (buy amount prize account)
    ;;   (trade prize amount account))
    (define (trade type amount prize account)
      (let ([total (* amount prize)])
        (if (equal? 'sell type)
            (hash-set* account
                       eur (+ (hash-ref account eur)
                              total)
                       xmr (- (hash-ref account xmr)
                              amount))
            (hash-set* account
                       eur (- (hash-ref account eur)
                              total)
                       xmr (+ (hash-ref account xmr)
                              amount)))))
    (define (sum)
      (for/fold ([acc (hash eur 100
                            xmr 20)])
                ([peak peak-seq])
        (let* ([peak-data (sequence->list peak)]
               [opening-prize (vector-ref (first peak-data) 1)]
               [closing-prize (vector-ref (last peak-data) 1)]
               [diff (- closing-prize opening-prize)]
               [amount 5]
               [prize closing-prize])
          (if (> diff 0)
              (trade 'sell amount prize acc)
              (trade 'buy amount prize acc)))))))
