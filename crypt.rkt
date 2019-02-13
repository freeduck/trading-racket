#lang racket
(require  net/uri-codec
          crypto
          crypto/libcrypto
          net/base64)
(crypto-factories (list libcrypto-factory))
(provide sign sha-256 hmac-sha512)

(define (sha-256 message)
  (digest 'sha256 message))

(define (hmac-sha512 secret message)
  (hmac 'sha512 secret
        message))

(define (sign data path secret)
  (define postdata (alist->form-urlencoded data))
  (define payload (string-append (cdr (assoc 'nonce data))
                                 postdata))
  (println (string-append "Payload: " payload))
  (define hashed (sha-256 payload))
  (println (string-append "Hashed 64: " (string-trim (bytes->string/utf-8 (base64-encode hashed)))))
  (define prefixed (bytes-append (string->bytes/utf-8 path) hashed))
  (println (string-append "Prefix 64: " (bytes->string/utf-8 (base64-encode prefixed))))

  (define signature (hmac-sha512 (base64-decode (string->bytes/utf-8 secret))
                                 prefixed))
  (bytes->string/utf-8 (base64-encode signature "")))

(module+ test
  (require rackunit net/uri-codec net/base64)
  (check-equal? (bytes->string/utf-8 (base64-encode (sha-256 "1547494295437hest=hjort&nonce=1547494295437")))
                "LDWL+6vVgUz8flA+GUGB43PGh5gJ4KzPDph/S8V6DLQ=\r\n")
  (define postdata '([nonce . "1547494295437"]
                     [hest . "hjort"]))
  (define path "/0/private/Balance")
  (define secret "2hC9xDAdhO287Y9DN4VSlfk3KwDKU0HKjSZbgteNZPA=")
  (check-equal? (sign postdata path secret)
                "78n0913GO6B7UFaSAQhVw8/xqTI1KV8J1S9l7Y6SYPCbhSl/AFl3zgng7amMbm464ydSmCi38cuO3gTRPOZrRg=="))
