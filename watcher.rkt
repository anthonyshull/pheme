#lang racket

(require json
         net/url)

(provide make-watcher)

(define (make-url namespace)
  (format "http://localhost:9999/apis/apps/v1/namespaces/~a/deployments" namespace))

(define (make-watch-url url resource-version)
  (format "~a?watch=1&resourceVersion=~a" url resource-version))

(define (get-json url)
   (call/input-url (string->url url)
                   get-pure-port
                   read-json))

(struct deployments (resource-version items))

(define (get-deployments url)
  (deployments "" (make-hash)))

(define (make-watcher out namespace)
  (let* ([url (make-url namespace)]
         [deployments (get-deployments url)])
    (thread
     (lambda ()
       (let loop ()
         ; watch for changes & send old/new to processor
         (loop))))))