#lang racket
(require plot)
;; (plot-new-window? #t)
;; (require plot/snip)

(provide plot-with-x-as-time (all-from-out plot))

(define (plot-with-x-as-time xy)
  (parameterize ([plot-x-ticks (date-ticks)])
    (plot-snip xy)))
