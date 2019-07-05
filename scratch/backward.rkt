#lang racket
(require "../fit.rkt"
         "../data-mangling.rkt"
         "../test.rkt"
         plot
         threading)

(define (find-peak-in-list data-source)
  (let-values ([(peak data-series) (for/fold ([peak #f] [old-data '()])
                                             ([bin (in-list (reverse data-source))]
                                              #:break peak)
                                     (let ([data (append bin old-data)])
                                       (values (find-peak data) data)))])
    peak))

(define find (λ (data)
               (let-values ([(peak data-series) (find-peak-in-list data)])
                 data-series)))
(parameterize ([data-path ".."])
  (~> (test-data-source noise-start aprox-peak-after-noise)
      slice-data
      find-peak-in-list
      regression-analysis-window
      lines
      plot))
