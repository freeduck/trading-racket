#lang racket
(require math plot)

(provide find-peak squared-error evaluate-models linear-regression poly fit fit-data extract transpose make-fitf peak-at
         (struct-out regression-analysis))

(define xs '(0 1  2  3  4  5   6   7   8   9  10))
(define ys '(1 6 17 34 57 86 121 162 209 262 321))
;; points : (listof (list/c real real)) ; list of (x y) coordinates
;; Returns a, b and f(x)=ax+b.
;; Source: https://gist.githubusercontent.com/spdegabrielle/f28cd93ffca4e3086d2ab0bd66bd802d/raw/cd526b64f19a1c5cfc3d9d626fa58cddd497d3d6/Metaxal-bazaar-math.rkt
(define (linear-regression points)
  (with-handlers ([exn:fail:contract:divide-by-zero?
                   (lambda (exn) (values #f #f #f))])
    (define n (length points))
    (define xs (map first points))
    (define ys (map second points))
    (define sum-x (apply + xs))
    (define sum-y (apply + ys))
    (define sum-x2 (apply + (map sqr xs)))
    (define sum-xy (apply + (map * xs ys)))
    (define a (/ (- sum-xy (* (/ n) sum-x sum-y))
                 (- sum-x2 (* (/ n) (sqr sum-x)))))
    (define b (/ (- sum-y (* a sum-x)) n))
    (values a b (λ(x)(+ (* a x) b)))))
;; Polynomial/Multiple regression
;; Source: https://rosettacode.org/wiki/Category:Racket
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
  (define fit-vector (apply fit
                            (append (transpose data)
                                    '(2))))
  (values fit-vector (poly fit-vector)))

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
         (fitf (let-values ([(v fitf) (make-fitf data)])
                 fitf))
         (x-max-y (x-for-max-y data xs fitf))
         (x-min-y (x-for-min-y data xs fitf))
         (peak (cond
                 [(and (not (= x-max-y (first xs)))
                       (not (= x-max-y (last xs)))) x-max-y]
                 [(and (not (= x-min-y (first xs)))
                       (not (= x-min-y (last xs)))) x-min-y]
                 [else #f]))]
    (values peak fitf)))

(define (evaluate-models data . functions)
  (first (foldl (lambda (error-sum-f f)
                  (if (not f)
                      error-sum-f
                      (if (< (second error-sum-f)
                             (second f))
                          error-sum-f
                          f)))
                #f
                (let* ([errors (for*/list ([f functions]
                                           [data-point data])
                                 (let* ([estimate (f (vector-ref data-point 0))]
                                        [error^2 (expt (- (vector-ref data-point 1) estimate) 2)])
                                   (list f error^2)))])
                  (for/list ((f functions))
                    (let ([ferrors (takef errors (lambda (error-point)
                                                   (equal? (first error-point) f)))])
                      (list f (for/sum ((error-point ferrors))
                                (second error-point)))))))))

(define (squared-error fitf data)
  (for/sum ((data-point data))
    (expt (- (vector-ref data-point 1) (fitf (vector-ref data-point 0))) 2)))

(struct linear-coeffiecients (a b))
(struct quadratic-coefficents linear-coeffiecients (c))
(struct regression-analysis (polyfun
                             linearfun
                             linear-slope
                             coefficient-1st-exponent
                             qv
                             xmom
                             window))

(define (find-min-or-max b a)
  (with-handlers ([exn:fail:contract:divide-by-zero?
                   (lambda (exn) #f)])
    (/ (- b)
       (* 2 a))))

(define (find-peak rows)
  (define-values (a b lfit) (linear-regression (map vector->list rows)))
  (define-values (v pfit) (make-fitf rows))
  (define les (squared-error lfit rows))
  (define pes (squared-error pfit rows))
  (define qa (vector-ref v 2))
  (let* ([qb (vector-ref v 1)]
         [x-for-min-or-max (find-min-or-max qb qa)])
    (if (or (< les pes)
            x-for-min-or-max)
        #f
        (regression-analysis pfit lfit a (vector-ref v 1) v x-for-min-or-max rows))))
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
