#lang racket
(require db sql
         crypto-trading/math)
(provide data-range
         select-window)


(define ((select-window con) #:start [start #f] #:end [end #f])
  (let-values (([start end] (if (and start
                               end)
                          (values start end)
                          (let ([range (data-range con)])
                            (values (or start
                                        (vector-ref range 0))
                                    (or end
                                        (vector-ref range 1)))))))
    (query-rows con
                "select start,open from candles_EUR_XMR where start >= $1 and start < $2"
                start
                end)))

(define (data-range con)
  (query-row con "select min(start), max(start) as max from candles_EUR_XMR"))

(module+ test
  ;; (data-source #:start 1542579840 #:end 1550528280)
  ;; #(1550527860 44.34)
  ;; #(1550527920 44.34)
  ;; #(1550527980 44.49)
  ;; #(1550528040 44.49)
  ;; #(1550528100 44.49)
  ;; #(1550528160 44.49)
  ;; #(1550528220 44.49))
  (define con (sqlite3-connect #:database "/home/kristian/projects/crypto-trading/2018-11-18-22:21:00-2019-02-18-22:21:00.db"))
  (define (make-temp-con)
    (sqlite3-connect #:database (make-temporary-file)))
  (module+ all-data
    (define data-source (select-window con)))
  (module+ create-table
    (define con (make-temp-con))
    ;; (query-exec con "CREATE TABLE IF NOT EXIST")
    (define new-table (create-table #:if-not-exists trade_analysis
                                    #:columns
                                    [id integer #:not-null]
                                    [x integer #:not-null]
                                    [y integer #:not-null]
                                    #:constraints (primary-key id)))
    (define insert-trade (insert #:into trade_analysis
                                 #:set [x 1] [y 2]))
    (define select-all (select id x y
                               #:from trade_analysis))
    (define (test)
      (query-exec con new-table) 
      (query-exec con new-table) 
      (query-exec con insert-trade)
                                 
      (query-rows con select-all)
                                 
      (query-exec con insert-trade)
      (query-rows con select-all))))
