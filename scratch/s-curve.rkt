#lang racket

(require threading
         "../peak.rkt"
         "../plot.rkt"
         "../test.rkt")

(module+ test
  (define s-curve-data (parameterize ([data-path ".."])
                         (~> (select-single-ohlc-field)
                                                            (peaks #:peak? peak?)
                                                            (sequence-ref 5))))
  (define (plot-s-curve data-set)
    (~> data-set
        lines
        plot))
  (module+ take-from-list
    (time (~> s-curve-data
              sequence->list
              (drop 30)
              (take 450)
              lines
              plot)))
  (module+ just-plot
    (time (~> s-curve-data
              lines
              plot))))
