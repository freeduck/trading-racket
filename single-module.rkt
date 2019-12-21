#lang racket
(require db
         plot
         threading
         math)

(define (transpose data)
  (vector->list (apply vector-map list data)))

(define (fit x y n)
  (define Y (->col-matrix y))
  (define V (vandermonde-matrix x (+ n 1)))
  (define VT (matrix-transpose V))
  (matrix->vector (matrix-solve (matrix* VT V) (matrix* VT Y))))

(define (fit-data data [n 2])
  (apply fit
         (append (transpose data) (list n))))

(define kraken-db (sqlite3-connect #:database
                                   "/home/kristian/projects/gekko/history/kraken_0.1.db"))
(define rows (query-rows kraken-db "select start,open from candles_EUR_XMR where start < 1547247600"))
(define slices (in-slice 600 (in-list rows)))


