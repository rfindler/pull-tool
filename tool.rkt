#lang racket

#|

If there is some kind of network error, the error message
is treated as the downloaded program (see with-handlers below).

Perhaps this is not optimal....

there is also no way to abort the attempt or provide progress
information when things are going slowly.

|#

(provide tool@)
(require drracket/tool
         framework
         mrlib/switchable-button
         racket/runtime-path
         racket/gui/base
         net/url)

(define the-url (string->url "http://www.eecs.northwestern.edu/~robby/tmp/x.rkt"))

(define-runtime-path icon.png "icon.png")

(define-local-member-name fetch-code)

(define tool@
  (unit
    (import drracket:tool^)
    (export drracket:tool-exports^)

    (define fetch-code-frame-mixin
      (mixin (drracket:unit:frame<%> frame:editor<%>) ()
        (inherit get-editor)
        (define/public (fetch-code)
          (define c (make-channel))
          (thread
           (λ ()
             (define str
               (with-handlers ([exn:fail? exn-message])
                 (define sp (open-output-string))
                 (call/input-url the-url get-pure-port (λ (port) (copy-port port sp)))
                 (get-output-string sp)))
             (channel-put c str)))
          (define frame
            (cond
              [(send (get-editor) still-untouched?)
               this]
              [else
               (handler:edit-file #f)]))
          (define txt (send frame get-editor))
          (send txt begin-edit-sequence)
          (send txt erase)
          (send txt insert (channel-get c))
          (send txt end-edit-sequence))
        (super-new)))
    
    (drracket:get/extend:extend-unit-frame fetch-code-frame-mixin)
    
    (define (phase1)
      (drracket:module-language-tools:add-opt-out-toolbar-button
       (λ (frame parent)
         (new switchable-button%
              [label "Fetch Code"]
              [bitmap (read-bitmap icon.png)]
              [parent parent]
              [callback (λ (button) (send frame fetch-code))]))
       'push-tool))
    (define (phase2) (void))))

