#lang racket
(require "fit.rkt"
         "plot.rkt"
         crypto-trading/test-data
         crypto-trading/advicer
         crypto-trading/math)

(provide find-advice
         next-advice
         find-first-advice
         find-first-peak
         scan-window
         (all-from-out crypto-trading/test-data
                       crypto-trading/advicer)
         (struct-out trade-report))

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

(struct trade-report (timestamp analysis)
  #:property prop:procedure (lambda (self)(trade-report-timestamp self)))

(define (find-first-peak data-source start end [step 600])
  (for/fold ([t #f])
            ([current (in-range (+ start step) end step)]
             #:break t)
    (cond
      [(find-peak (data-source start current)) =>
                                               (lambda (a)
                                                 (trade-report current a))]
      [else #f])))
;; Returning trade-report not advice, this is confusing
(define (find-first-advice time-series [step 600])
  (define time-index 0)
  (define start (vector-ref (first time-series) time-index))
  (define end (vector-ref (last time-series) time-index))
  (for/fold ([t #f])
            ([window-end (in-range start end step)]
             #:break t)
    (define window (takef time-series (lambda (data-point)
                                        (<= (vector-ref data-point time-index)
                                            window-end))))
    (cond
      [(get-advice window) => (lambda (a)
                                (trade-report window-end a))]
      [else #f])))

(define (next-advice data-source start
                     #:initial-step [initial-step #f]
                     #:step [step 600]
                     [end (let ([end (+ step start)])
                            (if initial-step
                                (+ initial-step end)
                                end))]
                     [advice #f] )
  (if advice
      (values advice (- end step))
      (next-advice data-source start (+ step end) (get-advice (data-source start end)))))

(define (find-advice time-series #:step [step 600] [window-size step] [advice #f])
  (if advice
      advice
      (find-advice time-series
                   #:step step
                   (+ step window-size)
                   (get-advice (take time-series window-size)))))

(define (find-peak-with-fft data-set)
  (for/fold [(peak #f)]
            [(window-end (in-range 600 (+ 1 (length data-set)) 600))
             #:break peak]
    (let* ([freq-mag (fft (take data-set (min window-end (length data-set))))]
           [_ (displayln (min window-end (length data-set)))]
           [max-mag (vector-ref (first freq-mag) 1)])
      (if (> max-mag 100000)
          window-end
          #f))))
;; good
(define (find-peak-with-fft-sliced data-set)
  (let-values ([(found_peak
                 data) (for/fold [(peak #f) (window '())]
                                 [(slot (in-slice 600 (in-list data-set)))
                                  #:break peak]
                         (let* ([data (append window slot)]
                                [freq-magnitude (fft data)]
                                [max-mag (vector-ref (first freq-magnitude) 1)])
                           (values (> max-mag 100000) data)))])
    (if found_peak
        data
        #f)))

(module+ test
  ;; (define test-data-source test-data-source)
  (define rows (test-data-source latest-trade hour-past-first-fit))
  (define-values (first-peak fitf) (scan-window latest-trade hour-past-first-fit test-data-source))
  (define peak-rows (test-data-source latest-trade first-peak))
  (define plotables (list (lines rows)
                          (lines peak-rows)
                          (function fitf latest-trade first-peak)))
  (plot-on-frame plotables))
