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

(define trade-epoc
  (lambda~> sequence->list
            last
            (vector-ref 0)))
(module+ test
  (module+ to-json
    (define (first-ten)
      (define peak-seq (peaks (select-single-ohlc-field)))
      (define the-ten (for/list ([p peak-seq])(trade-epoc p)))
      (with-output-to-file "trade.json"
        (λ () (printf (jsexpr->string the-ten))))
      ;; (with-output-to-file some-file
    ;; (lambda () (printf "hello world")))
      ))
  (module+ iterate
    (define raw-data (parameterize ([data-path "/home/kristian/projects/gekko/history"]
                                    [*db* "kraken_0.1.db"])
                       (select-single-ohlc-field)))
    (define data-seq (in-slice 600 (in-list raw-data)))
    (define (print)
      (for/list ([s (in-sequences data-seq)])s)))
  (module+ speed
    (require db)
    (define kraken-db (sqlite3-connect #:database
                                       "/home/kristian/projects/gekko/history/kraken_0.1.db"))
    (for/fold ([cnt 0])([(point-in-time prize) (in-query kraken-db "select start,open from candles_EUR_XMR")])(+ cnt prize)))
  (require rackunit
           db
           sql
           "test-data.rkt"
           "peak.rkt"
           "data.rkt")
  (define peak-seq (peaks (select-single-ohlc-field)))
  (define con (make-temp-con))
  (define analysis (new analysis% [connection con])))
