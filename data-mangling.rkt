#lang racket

(provide
 slice-data
 transpose)

(define (slice-data data-set)
  (sequence->list (in-slice 600 (in-list data-set))))

(define (transpose data)
  (vector->list (apply vector-map list data)))
