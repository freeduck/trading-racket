#lang racket
(require "fit.rkt"
         "plot.rkt"
         crypto-trading/test-data)

(provide scan-window)

(define latest-trade 1542579840)

(define hour-past-first-fit 1542734640)

(define (scan-window start end row-db)
  (for/fold ([apeak #f]
             [fitf #f])
            ([current (in-range (+ start 600) end 600)]
             #:break apeak)
    (let*-values ([(rows) (row-db start current)]
                  [(peak fitf) (peak-at rows)]
                  [(apeak) (if peak
                               peak
                               apeak)])
      (values apeak fitf))))


(define (first-peak)
  (scan-window latest-trade hour-past-first-fit data-source))

(define (plot-peaks)
  ;; (define data-source data-source)
  (define rows (data-source latest-trade hour-past-first-fit))
  (define-values (first-peak fitf) (scan-window latest-trade hour-past-first-fit data-source))
  (define peak-rows (data-source latest-trade first-peak))
  (define plotables (list

                          (function fitf latest-trade first-peak)))
  (plot-on-frame plotables))

(module+ test
  ;; (define data-source data-source)
  (define rows (data-source latest-trade hour-past-first-fit))
  (define-values (first-peak fitf) (scan-window latest-trade hour-past-first-fit data-source))
  (define peak-rows (data-source latest-trade first-peak))
  (define plotables (list (lines rows)
                          (lines peak-rows)
                          (function fitf latest-trade first-peak)))
  (plot-on-frame plotables))
