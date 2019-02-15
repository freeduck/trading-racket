#lang racket
(require http/request)
(require net/http-client json)
(require net/uri-codec net/base64)
(require "crypt.rkt")
(provide asset-info balance)
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

(define (parirs)
  (define-values (status header response)
    (http-sendrecv "api.kraken.com" "/0/public/AssetPairs" #:ssl? 'tls))
  (define data (read-json response))
  (println data))

(define (buy apikey secret amount)
  (let* ([nonce (number->string
                 (current-milliseconds))]
         [version "0"]
         [query-path "private/AddOrder"]
         [path (string-append "/" version "/" query-path)]
         [post-data (list (cons 'ordertype "market")
                          (cons 'pair "XMREUR")
                          (cons 'type "buy")
                          (cons 'nonce  nonce)
                          (cons 'volume (number->string amount)))]
         [sig (sign post-data path secret)])
    (define-values (status header response)
      (http-sendrecv "api.kraken.com"
                     path
                     #:ssl? #t
                     #:method "POST"
                     #:data (alist->form-urlencoded post-data)
                     #:headers (list (string-append "API-key: "
                                                    apikey)
                                     (string-append "API-sign: "
                                                    sig))))
    (define data (read-json response))
    (println data)))

(define (balance apikey secret)
  (let* ([nonce (number->string
                 (current-milliseconds))]
         [version "0"]
         [query-path "private/Balance"]
         [path (string-append "/" version "/" query-path)]
         [post-data (list (cons 'nonce  nonce))]
         [sig (sign post-data path secret)])
    (define-values (status header response)
      (http-sendrecv "api.kraken.com"
                     path
                     #:ssl? #t
                     #:method "POST"
                     #:data (alist->form-urlencoded post-data)
                     #:headers (list (string-append "API-key: "
                                                    apikey)
                                     (string-append "API-sign: "
                                                    sig))))
    (define data (read-json response))
    (println data)))

(module+ test
  (require "config.rkt")
  (define get-config (create-config "~/kraken.yaml"))
  (buy (get-config "key")
       (get-config "secret")
       1))
