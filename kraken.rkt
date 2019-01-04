#lang racket
(require http/request)
(require net/http-client json)
(require net/uri-codec)
(define (list-assets)
  (define-values (in out) (connect "http" "www.google.com" 80))
  (println in)
  (println out)
  (disconnect in out))

(define (asset-info)
  (define-values (status header response)
    (http-sendrecv "api.kraken.com" "/0/public/Assets" #:ssl? 'tls))
  (define data (read-json response))
  (println data))

(define (balance)
  (define post-data (list
                     (cons 'nonse (number->string
                                   (current-milliseconds)))))
  (define-values (status header response)
    (http-sendrecv "api.kraken.com"
                   "/0/private/Balance"
                   #:ssl? 'tls
                   #:method "POST"
                   #:data (alist->form-urlencoded post-data)))
  (define data (read-json response))
  (println data))
