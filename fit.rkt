#lang racket
(require math plot)

(provide poly fit fit-data extract transpose make-fitf peak-at)

(define xs '(0 1  2  3  4  5   6   7   8   9  10))
(define ys '(1 6 17 34 57 86 121 162 209 262 321))

(define (fit x y n)
  (define Y (->col-matrix y))
  (define V (vandermonde-matrix x (+ n 1)))
  (define VT (matrix-transpose V))
  (matrix->vector (matrix-solve (matrix* VT V) (matrix* VT Y))))

(define (extract data)
  (values (map (lambda (v)(vector-ref v 0)) data)
          (map (lambda (v)(vector-ref v 1)) data)))

(define (transpose data)
  (vector->list (apply vector-map list data)))

(define (fit-data data [n 2])
  (apply fit
         (append (vector->list (transpose data))
                 (list n))))


(define ((poly v) x)
  (for/sum ([c v] [i (in-naturals)])
    (* c (expt x i))))


(define (make-fitf data)
  (poly (apply fit
               (append (transpose data)
                       '(2)))))

(define (x-for-_-y data xs fitf operator)
  (foldl (lambda (x a)
           (if (operator (fitf a)
                         (fitf x))
               x
               a))
         (car xs)
         xs))

(define (x-for-max-y data xs fitf)
  (x-for-_-y data xs fitf <))

(define (x-for-min-y data xs fitf)
  (x-for-_-y data xs fitf >))

(define (peak-at data)
  (let* [(xs (first (transpose data)))
         (fitf (make-fitf data))
         (x-max-y (x-for-max-y data xs fitf))
         (x-min-y (x-for-min-y data xs fitf))
         (peak (cond
                 [(and (not (= x-max-y (first xs)))
                       (not (= x-max-y (last xs)))) x-max-y]
                 [(and (not (= x-min-y (first xs)))
                       (not (= x-min-y (last xs)))) x-min-y]
                 [else #f]))]
    (values peak fitf)))



;; (module+ test
;;   (require db)
;;   (require "data.rkt")
;;   (define *db*
;;     (sqlite3-connect #:database
;;                      "data/ohcl-2018-08-22-00:17:13.sqlite"))
;;   (define s-curve-data (date-range *db*
;;                                    '(0 50 18 21 8 2018)
;;                                    '(0 20 21 21 8 2018))))
;; (plot (list (points   (map vector xs ys))
;;             (function (poly (fit xs ys 2)))))
