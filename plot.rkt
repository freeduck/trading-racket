#lang racket
(require db
         racket/gui
         mrlib/snip-canvas
         plot)
(define *db*
  (sqlite3-connect #:database
                   "2018-11-18-22:21:00-2019-02-18-22:21:00.db"))
(define x-min 1542579840)
(define x-max (+ 1542579840 (* 3600 40)))
(define rows (query-rows *db*
                         "select start,open from candles_EUR_XMR where start >= $1 and start < $2"
                         x-min
                         x-max))

(define (mouse-callback snip event x y)
  (if (and x y)
      (begin
        (send snip set-overlay-renderers
              (list (vrule x)))
        (when (eq? (send event get-event-type) 'left-down)
          (println  (round x))))

      (send snip set-overlay-renderers #f)))
(define y-min (vector-ref (argmin (lambda (v)(vector-ref v 1)) rows) 1))
(define y-max (vector-ref (argmax (lambda (v)(vector-ref v 1)) rows) 1))

(define  (make-2d-plot-snip data width height)
  (define snip (plot-snip (list (lines rows))
                          #:x-min x-min #:x-max x-max
                          #:y-min y-min #:y-max y-max))
  (send snip set-mouse-event-callback mouse-callback)
  snip)

(define toplevel (new frame% [label "Plot"] [width 500] [height 500]))
(define canvas (new snip-canvas%
                    [parent toplevel]
                    [make-snip (lambda (width height)
                                 (make-2d-plot-snip rows width height))]))
(send toplevel show #t)
