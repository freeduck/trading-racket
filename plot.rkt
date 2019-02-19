#lang racket
(require db
         "plot-ohlc.rkt")
(define *db*
  (sqlite3-connect #:database
                   "2018-11-18-22:21:00-2019-02-18-22:21:00.db"))

(define rows (query-rows *db*
                         "select start,open from candles_EUR_XMR"))
(parameterize ([plot-new-window? #t])
  (plot-with-x-as-time (list (points rows))))
