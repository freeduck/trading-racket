#lang racket
(require db
         sql)
(define  trade-analysis-table "trade_analysis")
(define (ensure-trade-analysis-table con)
  (query-exec con
              (create-table #:if-not-exists (Ident:AST ,(make-ident-ast trade-analysis-table))
                            #:columns
                            [id integer #:not-null]
                            [x integer #:not-null]
                            [y integer #:not-null]
                            #:constraints (primary-key id))))
(module+ test
  (require rackunit
           db
           sql
           "test-data.rkt"
           "peak.rkt"
           "data.rkt")
  (define peak-seq (peaks (select-single-ohlc-field)))
  (define con (make-temp-con))
  (ensure-trade-analysis-table con))
