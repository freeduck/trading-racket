#lang racket
(require "../advicer.rkt"
         "../peak.rkt"
         "../data-mangling.rkt"
         "../test.rkt"
         "../query.rkt"
         racket/generator
         plot
         threading)
(define (append-slices slices)
  (in-generator
             (for/fold ([data-accum '()])
                       ([slice (in-list (reverse slices))])
               (let ([cur-data (append slice data-accum)])
                 (yield cur-data)
                 cur-data))))
(define (validate-data peak-analysis)
    (and~> peak-analysis
           within-prize-threshold?))
(define (find-peak-in-list data-source validate-data-fn)
    (let-values ([(data goot-peak) (for/fold ([prev-data '()] [good-peak #f])
                                             ([bin (in-list (reverse data-source))]
                                              #:break (regression-analysis? peak-at))
                                     (let ([data (append bin prev-data)])
                                       (values data (and~> data
                                                           validate-data-fn
                                                           data-set->parabola
                                                           validate-peak))))])
      data))

  (define (within-prize-threshold? time-series (threshold 0.02))
    (let ([numeric-threshold (* threshold (first-prize-in-series time-series))])
      (if (> (prize-delta time-series)
             numeric-threshold)
          time-series
          #f)))
(module+ main
  (parameterize ([data-path ".."])
    (define sliced-data (~> (test-data-source noise-start aprox-peak-after-noise)
                            slice-data))
    (validate-data (append-slices sliced-data))))
(module+ test
  (parameterize ([data-path ".."])
    (for/first ([part (~> (test-data-source first-trade second-trade-target)
                          slice-data
                          append-slices)]
                #:when (and~> part
                              data-set->parabola
                              validate-peak))
      (plot (lines part)))))

;; (parameterize ([data-path ".."])
;;   (and~> (test-data-source noise-start aprox-peak-after-noise)
;;          slice-data
;;          (find-peak-in-list validate-data)
;;          lines
;;          plot))

;; (and~> data-set
;;        validate-data
;;        data-set->parabola
;;        ((λ (p)
;;           (begin
;;             (displayln p)
;;             #t))))
