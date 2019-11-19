#lang racket
(require db
         crypto-trading/math)
(provide select-window)


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
  (define data-source (select-window con)))
