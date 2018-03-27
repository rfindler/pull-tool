#lang info

(define drracket-tools      '("tool.rkt"))
(define drracket-tool-names '("Pull Code"))

(define collection 'use-pkg-name)
(define deps '("base"
               "drracket-plugin-lib"
               "gui-lib"))
(define build-deps '())
(define pkg-desc "A DrRacket tool to easily share one-off code examples")
(define version "1.0")
