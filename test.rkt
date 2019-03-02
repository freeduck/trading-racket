#lang racket
(require db
         "fit.rkt"
         "data.rkt")
(define *db*
  (sqlite3-connect #:database
                   "2018-11-18-22:21:00-2019-02-18-22:21:00.db"))

(define latest-trade 1542579840)

(define hour-past-first-fit 1542734640)

(define (scan-window start end row-db)
  (for/fold ([peak #f])
            ([current (in-range (+ start 600) end 600)]
             #:break peak)
    (let* ([rows (row-db start current)]
           [peak (peak-at rows)])
      (when peak
        peak))))


(define (first-peak)
  (scan-window latest-trade hour-past-first-fit (select-window *db*)))
