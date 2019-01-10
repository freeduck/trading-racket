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

(module+ main
  (define (create-config yaml-config-path)
    (define config-yaml (file->yaml (path->string (expand-user-path yaml-config-path))))
    (lambda (key)
      (hash-ref config-yaml key)))
  (define get-config (create-config "~/kraken.yaml"))
  ;; Main entry point, executed when run with the `racket` executable or DrRacket.
  (bytes->string/latin-1 (base64-decode (string->bytes/latin-1 (get-config "secret"))))
  (println "Hello, World!"))
