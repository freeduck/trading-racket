#lang racket
(require "../test.rkt"
         "../data-mangling.rkt"
         "../fit.rkt"
         "../peak.rkt"
         "../plot.rkt"
         threading)
(module+ test
  (require rackunit)
  (define test-data (parameterize ([data-path ".."])
                      (select-single-ohlc-field)))
  (define (plot-peak-# number)
    (~> test-data
        peaks
        (sequence-ref (- 1 number)) 
        lines
        plot))
  (module+ main
    (displayln "Hest"))
  (module+ first
    (plot-peak-# 1))
  (module+ second
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          (peaks #:peak? peak?)
          (sequence-ref 1) 
          lines
          plot)))
  (module+ third
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          peaks
          (sequence-ref 2) 
          lines
          plot)))
  (module+ fourth
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          (peaks #:peak? peak?)
          (sequence-ref 3) 
          lines
          plot)))
  (module+ fifth
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          peaks
          (sequence-ref 4) 
          lines
          plot)))
  (module+ sixth
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          peaks
          (sequence-ref 5) 
          lines
          plot)))
  (module+ seventh
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          peaks
          (sequence-ref 6) 
          lines
          plot)))

  (module+ eighth
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          peaks
          (sequence-ref 7) 
          lines
          plot))))
