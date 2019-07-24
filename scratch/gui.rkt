#lang racket
(require racket/gui
         threading
         "../peak.rkt"
         "../plot.rkt")
(module+ test
  (require "../test.rkt")
  (define test-data (parameterize ([data-path ".."])
                      (~> (select-single-ohlc-field)
                          peaks)))
  (module+ update-plot
    (define window (new frame% [label "Plot"] [width 500] [height 500]))
    (define graph (new canvas% [parent window]))
    (send window show #t)
    (~> test-data
        (sequence-ref 1)
        lines
        (plot/dc (send graph get-dc) 0 0 500 500))))
