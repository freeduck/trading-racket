#lang racket

(require threading
         "../fit.rkt"
         "../peak.rkt"
         "../plot.rkt"
         "../test.rkt")

(module+ test
  (define s-curve-data (parameterize ([data-path ".."])
                         (~> (select-single-ohlc-field)
                             (peaks #:peak? peak?)
                             (sequence-ref 5))))
  (define s-curve-slice (~> s-curve-data
                            sequence->list
                            (drop 30)
                            (take 420)))
  (define (fit-s-curve data (order 3))
    (poly (fit-data data order)))
  (define fittedt-s-curve (fit-s-curve s-curve-slice))
  (module+ fit-it
    (fit-data s-curve-slice 2))
  (module+ plot-s-lines
    (~> (for/list ([x (~> s-curve-slice
                          transpose
                          first)])
          (vector x (fittedt-s-curve x)))
        lines
        plot-on-frame))

  (module+ parabola
    (plot (list (lines s-curve-slice)
                (function fittedt-s-curve
                          (vector-ref (first s-curve-slice) 0)
                          (vector-ref (last s-curve-slice) 0)))))
  
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
