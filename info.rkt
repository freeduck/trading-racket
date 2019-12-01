#lang info
(define collection "crypto-trading")
(define deps '("base"
               "rackunit-lib"
               "http"
               "yaml"
               "sha"
               "crypto-lib"
               "rsound"
               "threading"
               "memoize"
               "sql"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/crypto-trading.scrbl" ())))
(define pkg-desc "Description Here")
(define version "0.0")
(define pkg-authors '(kristian))
