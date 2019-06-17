#lang racket
(require db
         crypto-trading/math)
(provide select-window)
(define ((select-window con) start end)
  (query-rows con
              "select start,open from candles_EUR_XMR where start >= $1 and start < $2"
              start
              end))
