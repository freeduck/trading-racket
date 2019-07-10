#lang racket
(require threading)
(provide prize-delta
         first-prize-in-series
         last-prize-in-series)

(define (prize-delta time-series)
  (abs (- (last-prize-in-series time-series) (first-prize-in-series time-series))))

(define (first-prize-in-series time-series)
  (~> time-series
      sequence->list
      first
      get-prize))

(define (last-prize-in-series time-series)
  (~> time-series
      sequence->list
      last
      get-prize))

(define (get-prize vec)
  (vector-ref vec 1))



