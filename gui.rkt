#lang racket
(require racket/gui)

; Make a frame by instantiating the frame% class
(define frame (new frame% [label "Example"]))
(define panel (new horizontal-panel% [parent frame]))
(module+ play
  ; Make a static text message in the frame
  (define msg (new message% [parent frame]
                   [label "No events so far..."]))
  
  ; Make a button in the frame
  (new button% [parent frame]
       [label "Click Me"]
       ; Callback procedure for a button click:
       [callback (lambda (button event)
                   (send msg set-label "Button click"))])

  (new button% [parent panel]
       [label "Left"]
       [callback (lambda (button event)
                   (send msg set-label "Left click"))])
  (new button% [parent panel]
       [label "Right"]
       [callback (lambda (button event)
                   (send msg set-label "Right click"))])

  (new button% [parent frame]
       [label "Pause"]
       [callback (lambda (button event) (sleep 5))])

  ;; (new canvas% [parent fram]
  ;;      [paint-callback (lambda (dc)
  ;;                        (let ([data '()])))])

  ; Show the frame by calling its show method
  (send frame show #t))

(module+ plot
  (require plot
           mrlib/snip-canvas)
  (new button% [parent panel]
       [label "Right"]
       [callback (lambda (button event)
                   (send button set-label "Right click"))])
  (new )
  (new snip-canvas%
                      [parent panel]
                      [make-snip (lambda (width height)
                                   (make-2d-plot-snip width height plotables))])
  (send frame show #t))
