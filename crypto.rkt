#lang racket
(require net/uri-codec net/base64 sha)
(provide sha-256)

(define (sha-256 str)
  (sha256
   (string->bytes/utf-8 str)))

(module+ test
  (require rackunit)
  (check-equal? (bytes->string/utf-8 (base64-encode (sha-256 "1547494295437hest=hjort&nonce=1547494295437")))
                "LDWL+6vVgUz8flA+GUGB43PGh5gJ4KzPDph/S8V6DLQ=\r\n"))
