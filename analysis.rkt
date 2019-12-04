#lang racket
(require db
         sql)
(define  trade-analysis-table (make-parameter "trade_analysis"))
(define analysis% (class object%
                    (init connection)
                    (define con connection)
                    (query-exec con
                                (create-table #:if-not-exists (Ident:AST ,(make-ident-ast (trade-analysis-table)))
                                              #:columns
                                              [id integer #:not-null]
                                              [epoc integer #:not-null]
                                              #:constraints (primary-key id)))
                    (super-new)))
(define (insert-trade epoc)
  (insert #:into (Ident:AST ,(make-ident-ast (trade-analysis-table)))
          #:set [epoc ,epoc]))
(module+ test
  (require rackunit
           db
           sql
           "test-data.rkt"
           "peak.rkt"
           "data.rkt")
  (define peak-seq (peaks (select-single-ohlc-field)))
  (define con (make-temp-con))
  (define analysis (new analysis% [connection con])))
