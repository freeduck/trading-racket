#lang racket
(require http/request)
(require net/http-client json)
(require net/uri-codec net/base64)
(require "crypt.rkt")
(provide asset-info balance sign)
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

(define (balance apikey secret)
  (let* ([nonse (number->string
                 (current-milliseconds))]
         [version "0"]
         [query-path "private/Balance"]
         [path (string-append "/" version "/" query-path)]
         [post-data (list
                     (cons 'nonse nonse))]
         [sig (sign post-data path secret)])
    (define-values (status header response)
      (http-sendrecv "api.kraken.com"
                     path
                     #:ssl? 'tls
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
  (define postdata '([hest . "hjort"]
                     [nonce . "1547494295437"]))
  (sign postdata "/0/private/Balance" (get-config "secret")))
