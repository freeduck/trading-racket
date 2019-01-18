#lang racket/base

(module+ test
  (require rackunit))

;; Notice
;; To install (from within the package directory):
;;   $ raco pkg install
;; To install (once uploaded to pkgs.racket-lang.org):
;;   $ raco pkg install <<name>>
;; To uninstall:
;;   $ raco pkg remove <<name>>
;; To view documentation:
;;   $ raco docs <<name>>
;;
;; For your convenience, we have included a LICENSE.txt file, which links to
;; the GNU Lesser General Public License.
;; If you would prefer to use a different license, replace LICENSE.txt with the
;; desired license.
;;
;; Some users like to add a `private/` directory, place auxiliary files there,
;; and require them in `main.rkt`.
;;
;; See the current version of the racket style guide here:
;; http://docs.racket-lang.org/style/index.html

;; Code here
(require "kraken.rkt")
(require net/base64)
(require yaml)
(module+ test
  ;; Tests to be run with raco test
  )

(define (create-config yaml-config-path)
  (define config-yaml (file->yaml (path->string (expand-user-path yaml-config-path))))
  (lambda (key)
    (hash-ref config-yaml key)))

(module+ main
  (define get-config (create-config "~/kraken.yaml"))
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  (bytes->string/latin-1 (base64-decode (string->bytes/latin-1 (get-config "secret"))))
  (println "Hello, World!"))

(module+ test
  ;; Signature data
  ;; Postdata
  ;; hest=hjort&nonce=1547494295437
  ;; Encoded
  ;; b'1547494295437hest=hjort&nonce=1547494295437'
  ;; Message
  ;; b'/0/private/Balance,5\x8b\xfb\xab\xd5\x81L\xfc~P>\x19A\x81\xe3s\xc6\x87\x98\t\xe0\xac\xcf\x0e\x98\x7fK\xc5z\x0c\xb4'
  ;; Signature
  ;; <hmac.HMAC object at 0x7fda917935c0>
  ;; Sigdigest
  ;; b'U1ELyaQAlkTY8ABOQ1YZ6TbiWf7oHYNMCL9Z+fQEV/Zb0MR7xAUnwKkczuh8fewShhWV94eWLpQENZZ8qUeCeA=='
  ;; Sigdigest decoded
  ;; <built-in method decode of bytes object at 0x7fda932488b0>
  ;; U1ELyaQAlkTY8ABOQ1YZ6TbiWf7oHYNMCL9Z+fQEV/Zb0MR7xAUnwKkczuh8fewShhWV94eWLpQENZZ8qUeCeA==
  (require rackunit)
  (define get-config (create-config "~/kraken.yaml"))
  (define postdata '([hest . "hjort"]
                     [nonce . "1547494295437"]))
  (check-equal? (sign postdata "/0/private/Balance" (get-config "secret"))
                #"1547494295437hest=hjort&nonce=1547494295437"))
