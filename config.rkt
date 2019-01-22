#lang racket
(require yaml)
(provide create-config)
(define (create-config yaml-config-path)
  (define config-yaml (file->yaml (path->string (expand-user-path yaml-config-path))))
  (lambda (key)
    (hash-ref config-yaml key)))

(module+ test
  (require rackunit)
  (define get-config (create-config "credentials_yaml_fixture.yaml"))
  (check-equal? (get-config "user")
                1)
  (check-equal? (get-config "pass")
                2))
