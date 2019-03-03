#lang racket
(require db
         racket/gui
         mrlib/snip-canvas
         plot
         "fit.rkt")
(provide (all-from-out plot))

(define (mouse-callback snip event x y)
  (if (and x y)
      (begin
        (send snip set-overlay-renderers
              (list (vrule x)))
        (when (eq? (send event get-event-type) 'left-down)
          (println  (round x))))

      (send snip set-overlay-renderers #f)))

(define  (make-2d-plot-snip width height plotables)
  (define snip (plot-snip plotables))
  (send snip set-mouse-event-callback mouse-callback)
  snip)



(define (plot-on-frame plotables)
  (define toplevel (new frame% [label "Plot"] [width 500] [height 500]))
  (define canvas (new snip-canvas%
                      [parent toplevel]
                      [make-snip (lambda (width height)
                                   (make-2d-plot-snip width height plotables))]))
  (send toplevel show #t))

(module+ test
  (require "data.rkt")
  (define *db*
    (sqlite3-connect #:database
                     "2018-11-18-22:21:00-2019-02-18-22:21:00.db"))
  (define data-source (select-window *db*))
  (define x-min 1542579840)
  (define x-max (+ 1542579840 (* 3600 42)))
  (define rows (data-source x-min x-max))
  (define y-min (vector-ref (argmin (lambda (v)(vector-ref v 1)) rows) 1))
  (define y-max (vector-ref (argmax (lambda (v)(vector-ref v 1)) rows) 1))
  (println "Peak at")
  (println (peak-at rows))
  (define plotables (list (lines rows)
                          (function (make-fitf rows))))
  (plot-on-frame plotables))
