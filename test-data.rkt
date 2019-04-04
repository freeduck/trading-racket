#lang racket
(require db
         crypto-trading/data)
(provide test-data-source first-trade second-trade-target)
(define *db*
  (sqlite3-connect #:database
                   "2018-11-18-22:21:00-2019-02-18-22:21:00.db"))

(define test-data-source (select-window *db*))

(define first-trade 1542579840) ; found by hand
(define noise-start 1542831780)
(define aprox-noise-end 1542927156)
(define aprox-peak-after-noise 1542956099)
;; The second trade should be around here
(define second-trade-target (+ 1542579840 (* 3600 42)))
