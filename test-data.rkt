#lang racket
(require db
         crypto-trading/data
         memoize)
(provide aprox-peak-after-noise
         data-path
         noise-start
         aprox-noise-end
         test-data-source first-trade second-trade-target
         (all-from-out crypto-trading/data))
(define data-path (make-parameter "."))
;; (define *db*
;;   (sqlite3-connect #:database
;;                    (string-append (data-path) "/2018-11-18-22:21:00-2019-02-18-22:21:00.db")))
(define *db* (make-parameter "2018-11-18-22:21:00-2019-02-18-22:21:00.db"))
(define/memo (connect-test path)
  (select-window (sqlite3-connect #:database
                                  (string-append (data-path) "/" path))))
(define (test-data-source start end)
  ((connect-test (*db*)) start end))

(define first-trade 1542579840) ; found by hand
(define noise-start 1542831780)
(define aprox-noise-end 1542927156)
(define aprox-peak-after-noise 1542956099)
(define highest-magnitude-noise 60712.17+0.0i)
(define highest-magnitude-after-noise 14142.84+0.0i)
(define highest-magnitude-full-set 120091.11+0.0i)
;; The second trade should be around here
(define second-trade-target (+ 1542579840 (* 3600 42)))


(define (get-noise-data-set (start noise-start)
                            #:end (end aprox-peak-after-noise))
  (test-data-source start end))
