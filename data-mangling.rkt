#lang racket

(require racket/generator)

(provide
 slice-data
 append-slices
 prepend-slices
 transpose)

(define (slice-data data-set)
  (sequence->list (in-slice 600 (in-list data-set))))

(define (prepend-slices slices)
  (in-generator
             (for/fold ([data-accum '()])
                       ([slice (in-list (reverse slices))])
               (let ([cur-data (append slice data-accum)])
                 (yield cur-data)
                 cur-data))))

(define (append-slices slices #:yield-when (yield-when (λ () #t)))
  (in-generator
   (for/fold ([data-accum '()])
             ([slice (in-list slices)])
     (let*-values ([(cur-data) (append data-accum slice)])
       (cond [(yield-when cur-data) => (λ (y)
                                         (begin (yield y)
                                                '()))]
             [else cur-data])))))

(define (transpose data)
  (vector->list (apply vector-map list data)))
