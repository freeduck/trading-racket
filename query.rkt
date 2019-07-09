#lang racket
(require threading)
(provide first-prize-in-series last-prize-in-series)

(define (first-prize-in-series time-series)
  (~> time-series
      first
      get-prize))

(define (last-prize-in-series time-series)
  (~> time-series
      last
      get-prize))

(define (get-prize vec)
  (vector-ref vec 1))


