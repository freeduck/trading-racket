(define *db*
  (sqlite3-connect #:database
                   "2018-11-18-22:21:00-2019-02-18-22:21:00.db"))

(require crypto-trading/data)
(define data-source (select-window *db*))
(define first-trade 1542579840) ; found by hand
(define x-max (+ 1542579840 (* 3600 42)))
