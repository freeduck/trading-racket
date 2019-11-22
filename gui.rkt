#lang racket
(require racket/gui)

; Make a frame by instantiating the frame% class
(define frame (new frame% [label "Example"]
                   [width 600]
                   [height 600]))
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

  ; Show the frame by calling its show method
  (send frame show #t))

(module+ plot
  (require plot
           mrlib/snip-canvas
           db
           "data.rkt")
  (define database "/home/kristian/projects/crypto-trading/2018-11-18-22:21:00-2019-02-18-22:21:00.db")
  (define con (sqlite3-connect #:database database))
  (define data-source (select-window con))
  (let* ([x (build-list 10 values)]
         [y (list 2.7 2.8 31.4 38.1 58.0 76.2 100.5 130.0 149.3 180.0)]
         [y2 (list 2.7 2.8 131.4 38.1 158.0 76.2 100.5 130.0 149.3 180.0)]
         ;; [plotables (box (points (map vector x y)))]
         [plotables (box (lines (data-source)))]
         [plt (new snip-canvas% [parent panel]
                   [make-snip (lambda (width height)
                                (plot-snip (unbox plotables)))])]
         [dynamic-plot (new canvas%
                            [parent panel]
                            [paint-callback (λ (canvas dc)
                                              (plot/dc (unbox plotables)
                                                       dc
                                                       0 0
                                                       (send canvas get-width) (send canvas get-height)))])]
         [btn (new button% [parent panel]
                   [label "Right"]
                   [callback (lambda (button event)
                               
                               ;; (set-box! plotables (points (map vector x y2)))
                               (plot/dc (lines (map vector x y2)) (send plt get-dc) 0 0 200 200))])])
    (send frame show #t)))
