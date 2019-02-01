#lang racket
(require  net/uri-codec
          crypto
          crypto/libcrypto
          net/base64)
(crypto-factories (list libcrypto-factory))
(provide sha-256)

(define (sha-256 str)
  (digest 'sha256 str))

(define (sign data path secret)
  (define postdata (alist->form-urlencoded data))
  (define bpath (string->bytes/utf-8 path))
  (define strdata (string-append (cdr (assoc 'nonce
                                             data))
                                 postdata))
  (define bdata (sha-256 strdata))
  (define prefixed (bytes-append bpath
                                 bdata))
  (define signature (hmac 'sha256 (base64-decode (string->bytes/utf-8 secret))
                                 prefixed))
  signature)

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
