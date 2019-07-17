#lang racket
(require "../test.rkt"
         "../data-mangling.rkt"
         "../fit.rkt"
         "../peak.rkt"
         "../plot.rkt"
         threading)
(module+ test
  (require rackunit)
  (module+ main
    (displayln "Hest"))
  (module+ first
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          (peaks #:peak? peak?)
          (sequence-ref 0) 
          lines
          plot)))
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
          (peaks #:peak? peak?)
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
    ; Can we find a s-curve?
    (parameterize ([data-path ".."])
      (~> (select-single-ohlc-field)
          (peaks #:peak? peak?)
          (sequence-ref 4) 
          lines
          plot))))
