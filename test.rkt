#lang racket
(require db
         "fit.rkt")
(define *db*
  (sqlite3-connect #:database
                   "2018-11-18-22:21:00-2019-02-18-22:21:00.db"))
(define latest-trade 1542579840)
(define hour-past-first-fit 1542734640)
(for ([end (in-range (+ latest-trade 600) hour-past-first-fit 600)])
  (let* ([rows (query-rows *db*
                          "select start,open from candles_EUR_XMR where start >= $1 and start < $2"
                          latest-trade
                          end)]
         [peak (peak-at rows)])
    (when peak
        (println peak))))
