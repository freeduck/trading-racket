#lang racket
(provide sell
         buy
         (struct-out eur)
         (struct-out xmr)
         (struct-out account))
(define (sell amount account)
  (void))

(define (buy amount account)
  (void))

(struct account (currencies))

(struct currency (amount))
(struct xmr currency ())
(struct eur currency ())
