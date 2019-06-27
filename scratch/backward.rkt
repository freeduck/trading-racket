#lang racket
(require "../data-mangling.rkt"
         "../test.rkt")
(parameterize ([data-path ".."])
  (define rev-sliced-data (reverse (slice-data (test-data-source noise-start aprox-noise-end))))
  (displayln rev-sliced-data))
