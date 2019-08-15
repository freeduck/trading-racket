#lang racket
(provide (struct-out eur)
         (struct-out xmr)
         (struct-out account))



;; (define sell trade)
;; (define buy sell)

(struct account (currencies))

(struct currency (amount)
  #:property prop:procedure (λ (self)
                              (currency-amount self)))
(struct xmr currency ())
(struct eur currency ())
