#lang racket
(require "../fit.rkt"
         "../data-mangling.rkt"
         "../test.rkt"
         plot)
(parameterize ([data-path ".."])
  (define rev-sliced-data (reverse (slice-data (test-data-source noise-start aprox-peak-after-noise))))
  (let-values ([(peak data-series) (for/fold ([peak #f] [old-data '()])
                                             ([bin (in-list rev-sliced-data)]
                                              #:break peak)
                                     (let ([data (append bin old-data)])
                                       (values (find-peak data) data)))])
    (plot (lines data-series))))
