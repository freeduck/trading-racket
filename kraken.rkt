#lang racket
(require http/request)
(require net/http-client json)
(require net/uri-codec net/base64 sha)
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

(define (balance apikey)
  (let* ([nonse (number->string
                 (current-milliseconds))]
         [version "0"]
         [query-path "private/Balance"]
         [path (string-append "/" version "/" query-path)])
    (define post-data (list
                       (cons 'nonse nonse)))
    (define-values (status header response)
      (http-sendrecv "api.kraken.com"
                     path
                     #:ssl? 'tls
                     #:method "POST"
                     #:data (alist->form-urlencoded post-data)))
    (define data (read-json response))
    (println data)))

(define (sign data path secret)
  (define postdata (alist->form-urlencoded data))
  (define bpath (string->bytes/utf-8 path))
  (define bdata (sha256 (string->bytes/utf-8 (string-append (cdr (assoc 'nonce
                                                                        data))
                                                            postdata))))
  (define prefixed (bytes-append bpath
                                 bdata))
  (bytes->string/latin-1 (base64-encode (hmac-sha256 (base64-decode (string->bytes/utf-8 secret))
                                                     prefixed))))
