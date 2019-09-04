#lang racket
(require threading
         "../peak.rkt"
         "../test.rkt")
(define peak-seq (~> (parameterize ([data-path ".."])
                         (select-single-ohlc-field))
                       (peaks)))
(module+ peak-list
    (module+ serialize
      (define peak-list (sequence->list peak-seq))
      (module+ text
        (require racket/serialize)
        (with-output-to-file "peaks.txt"
          #:mode 'text
          #:exists 'replace
          (λ () (write (serialize peak-list)))))
      (module+ fasl
        (require racket/fasl)
        (with-output-to-file "peaks.b"
          #:exists 'replace
          (λ () (write (s-exp->fasl peak-list))))))
    (module+ deserialize
      (require racket/serialize)
      (define peak-list (deserialize (with-input-from-file "peaks.txt"
                                       (λ () (read)))))))
