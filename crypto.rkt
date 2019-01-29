#lang racket
(require  net/uri-codec
          sha)
(provide sha-256)

(define (sha-256 str)
  (sha256
   (string->bytes/utf-8 str)))

(define (sign data path secret)
  (define postdata (alist->form-urlencoded data))
  (define bpath (string->bytes/utf-8 path))
  (define strdata (string-append (cdr (assoc 'nonce
                                             data))
                                 postdata))
  (sha-256 strdata))

(module+ test
  (require rackunit net/uri-codec net/base64)
  (check-equal? (bytes->string/utf-8 (base64-encode (sha-256 "1547494295437hest=hjort&nonce=1547494295437")))
                "LDWL+6vVgUz8flA+GUGB43PGh5gJ4KzPDph/S8V6DLQ=\r\n")
  (define postdata '([hest . "hjort"]
                     [nonce . "1547494295437"]))
  (define path "/0/private/Balance")
  (define secret "2hC9xDAdhO287Y9DN4VSlfk3KwDKU0HKjSZbgteNZPA=")
  (check-equal? (bytes->string/utf-8 (base64-encode (sign postdata path secret)))
                "LDWL+6vVgUz8flA+GUGB43PGh5gJ4KzPDph/S8V6DLQ=\r\n"))
