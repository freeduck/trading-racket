#lang racket
(require crypto-trading/advicer
         crypto-trading/test
         crypto-trading/plot
         math)
(provide plot-first-advice)
(define (plot-first-advice)
  (define advice-index (find-first-advice (test-data-source first-trade (* 2 second-trade-target))))
  (define advice (trade-report-analysis advice-index))
  (define analysis (trade-advice-analysis advice))
  (define time-series (regression-analysis-window analysis))
  (define last-in-time-series (vector-ref (last time-series) 0))
  (define polyfun (regression-analysis-polyfun analysis))
  (define linearfun (regression-analysis-linearfun analysis))
  (displayln (advice-index))
  (plot-on-frame (list (lines (test-data-source first-trade second-trade-target))
                       (lines (test-data-source first-trade (advice-index))
                              #:color '(0 200 0))
                       (function linearfun first-trade (advice-index)
                                 #:color '(200 200 0))
                       (function polyfun first-trade (advice-index)
                                 #:color '(0 0 200))))
  (displayln (exact->inexact (/ (- (advice-index) first-trade) 3600)))
  (displayln last-in-time-series))

(define (plot-first-advice-in-window start end)
  (define advice-index (find-first-advice (test-data-source start (* 2 end))))
  (define advice (trade-report-analysis advice-index))
  (define analysis (trade-advice-analysis advice))
  (define time-series (regression-analysis-window analysis))
  (define last-in-time-series (vector-ref (last time-series) 0))
  (define polyfun (regression-analysis-polyfun analysis))
  (define linearfun (regression-analysis-linearfun analysis))
  (displayln (advice-index))
  (plot-on-frame (list (lines (test-data-source start end))
                       (lines (test-data-source start (advice-index))
                              #:color '(0 200 0))
                       (function linearfun start (advice-index)
                                 #:color '(200 200 0))
                       (function polyfun start (advice-index)
                                 #:color '(0 0 200))))
  (displayln (exact->inexact (/ (- (advice-index) start) 3600)))
  (displayln last-in-time-series))

(define (find-#-of-peaks x)
  (define-values (plotables final-start-x)
    (for/fold ([plotables '()]
               [start first-trade])
              ([x (in-range x)])
      (let*-values ([(advice last-x)
                     (next-advice test-data-source start)]
                    [(analysis)
                     (trade-advice-analysis advice)])
        (let ([slope (regression-analysis-linear-slope analysis)])
          (displayln (abs slope))
          (displayln (> (abs slope) 9e-05))
          (displayln (vector-ref (last (regression-analysis-window analysis)) 0))
          (values (append plotables
                          (analysis->plotables analysis))
                  last-x)))))
  plotables)

(define (find-#-of-peaks-from-start x start)
  (define-values (plotables final-start-x)
    (for/fold ([plotables '()]
               [start start])
              ([x (in-range x)])
      (let*-values ([(advice last-x)
                     (next-advice test-data-source start)]
                    [(analysis)
                     (trade-advice-analysis advice)])
        (let ([slope (regression-analysis-linear-slope analysis)])
          (displayln (abs slope))
          (displayln (> (abs slope) 9e-05))
          (displayln (vector-ref (last (regression-analysis-window analysis)) 0))
          (values (append plotables
                          (analysis->plotables analysis))
                  last-x)))))
  plotables)

(define (plot-#-of-peaks x)
  ((plot-new-window? #t)
   (plot (append (list (lines (test-data-source first-trade (+ first-trade 497880))
                              #:color '(0 200 200)))
                 (find-#-of-peaks x)))))

(define (plot-#-of-peaks-with-ruler x)
  ((plot-new-window? #t)
   (plot-on-frame (append (list (lines (test-data-source first-trade (+ first-trade 497880))
                                       #:color '(0 200 200)))
                          (find-#-of-peaks x)))))

(define (strip-to-power-of-two l)
  (if (power-of-two? (length l))
      l
      (strip-to-power-of-two (cdr l))))

(define (remove-noise-fft (start noise-start) (end aprox-noise-end))
  (let* ([data-set (test-data-source start end)])
    (array-fft (list->array (strip-to-power-of-two (second (transpose data-set)))))))


(define (reverse-data-find-peak)
  (let* ([data-set (test-data-source noise-start aprox-peak-after-noise)]
         [advice-index (find-first-advice (flip data-set))]
         [analysis (trade-advice-analysis (trade-report-analysis advice-index))]
         [xmom (compose1
                regression-analysis-xmom
                trade-advice-analysis
                trade-report-analysis)])
    (plot-new-window? #t)
    (plot (lines data-set))
    (plot-on-frame (analysis->plotables analysis))
    (xmom advice-index)))
