#lang racket
(require "../fit.rkt"
         "../data-mangling.rkt"
         "../test.rkt"
         plot)

(define (find-peak-in-list data-source)
  (for/fold ([peak #f] [old-data '()])
            ([bin (in-list data-source)]
             #:break peak)
    (let ([data (append bin old-data)])
      (values (find-peak data) data))))

(parameterize ([data-path ".."])
  (define rev-sliced-data (reverse (slice-data (test-data-source noise-start aprox-peak-after-noise))))
  (let-values ([(peak data-series) (find-peak-in-list rev-sliced-data)])
    (plot (lines data-series))))
