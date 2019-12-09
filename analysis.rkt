#lang racket
(require db
         sql
         json
         threading)
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

(define (trade-epoc window)
  (~> window
      (sequence-ref 0)
      (vector-ref 0)))
(module+ test
  (module+ to-json
    (define (first-ten)
      (define peak-seq (peaks (select-single-ohlc-field)))
      (define the-ten (stream->list (stream-take (for/stream ([p (sequence->stream peak-seq)])(trade-epoc p)) 10)))
      (with-output-to-file "trade.json"
        (λ () (printf (jsexpr->string the-ten))))
      ;; (with-output-to-file some-file
    ;; (lambda () (printf "hello world")))
      ))
  (require rackunit
           db
           sql
           "test-data.rkt"
           "peak.rkt"
           "data.rkt")
  (define peak-seq (peaks (select-single-ohlc-field)))
  (define con (make-temp-con))
  (define analysis (new analysis% [connection con])))
