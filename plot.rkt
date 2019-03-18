#lang racket
(require racket/gui
         mrlib/snip-canvas
         plot
         crypto-trading/fit)
(provide analysis->plotables plot-on-frame (all-from-out plot))

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

(define (analysis->plotables analysis)
  (let* ([time-series (regression-analysis-time-series analysis)]
         [first-x (vector-ref (first time-series) 0)]
         [last-x (vector-ref (last time-series) 0)]
         [linearfun (regression-analysis-linearfun analysis)]
         [polyfun (regression-analysis-polyfun analysis)])
    (list (lines time-series)
          (function polyfun first-x last-x
                    #:color '(200 200 0))
          (function linearfun first-x last-x
                    #:color '(0 0 200)))))

(module+ test
  (require crypto-trading/test-data
           crypto-trading/fit)
  (define x-min 1542579840)
  (define x-max (+ 1542579840 (* 3600 42)))
  (define rows (test-data-source x-min x-max))
  (define y-min (vector-ref (argmin (lambda (v)(vector-ref v 1)) rows) 1))
  (define y-max (vector-ref (argmax (lambda (v)(vector-ref v 1)) rows) 1))
  (define plotables (list (lines rows)
                          (function (let-values ([(v fitf) (make-fitf rows)])
                                      fitf))))
  (plot-on-frame plotables))
