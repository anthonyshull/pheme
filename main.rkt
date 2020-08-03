#lang racket

(require net/rfc6455)

(require "processor.rkt"
         "publisher.rkt"
         "watcher.rkt")

(define namespace (make-parameter "default"))

(define parser
  (command-line
   #:usage-help
   "Watch deployments in a namespace and broadcast their diffs"
   #:once-each
   [("-n" "--namespace") NAMESPACE
                         "the namespace to watch"
                         (namespace NAMESPACE)]
   #:args () (void)))

(module+ main
  (let* ([publisher (make-publisher)]
         [processor (make-processor publisher)]
         [watcher (make-watcher processor (namespace))])
    (ws-serve #:port 9999 (lambda (c _) (thread-send publisher c)))
    (printf "Server started...watching deployments in ~s namespace" (namespace))))
