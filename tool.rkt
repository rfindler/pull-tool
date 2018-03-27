#lang racket

(provide tool@)
(require drracket/tool
         framework
         racket/runtime-path
         racket/gui/base
         net/url)

(define the-url
  (string->url "http://www.eecs.northwestern.edu/~jesse/tmp/pull-tool.rkt"))

(define-local-member-name fetch-code)

(define tool@
  (unit
    (import drracket:tool^)
    (export drracket:tool-exports^)

    (define fetch-code-frame-mixin
      (mixin (drracket:unit:frame<%> frame:editor<%>) ()
        (inherit get-editor create-new-tab)

        (define/override (file-menu:between-open-and-revert file-menu)
          (new menu:can-restore-menu-item%
               [label "Open 111 Code"]
               [parent file-menu]
               [shortcut #\1]
               [shortcut-prefix (cons 'shift (get-default-shortcut-prefix))]
               [callback (λ (_1 _2) (fetch-code))])
          (super file-menu:between-open-and-revert file-menu))
        
        (define/public (fetch-code)
          (define tmp-file (make-temporary-file "drracket-pull-tool~a"))
          (dynamic-wind
           void
           (λ ()
             (define err-msg
               (call-with-output-file tmp-file
                 (λ (out-port)
                   (with-handlers ([exn:fail? exn-message])
                     (call/input-url the-url
                                     get-pure-port
                                     (λ (in-port) (copy-port in-port out-port)))))
                 #:exists 'truncate))
             (cond
               [(string? err-msg)
                (message-box "DrRacket" err-msg)]
               [else
                (define frame
                  (cond
                    [(send (get-editor) still-untouched?)
                     this]
                    [(preferences:get 'drracket:open-in-tabs)
                     (create-new-tab)
                     this]
                    [else
                     (handler:edit-file #f)]))
                (define txt (send frame get-editor))
                (send txt begin-edit-sequence)
                (send txt erase)
                (send txt load-file tmp-file)
                (send txt set-filename #f)
                (send txt end-edit-sequence)]))
           (λ () (delete-file tmp-file))))
        (super-new)))
    
    (drracket:get/extend:extend-unit-frame fetch-code-frame-mixin)
    
    (define (phase1) (void))
    (define (phase2) (void))))

