#lang racket

(require json
         net/url)

(provide make-watcher)

(define (make-url namespace)
  (format "http://localhost:8888/apis/apps/v1/namespaces/~a/deployments" namespace))

(define (make-watch-url url resource-version)
  (format "~a?watch=1&resourceVersion=~a" url resource-version))

(define (get-json url)
   (call/input-url (string->url url)
                   get-pure-port
                   read-json))

(struct state (resource-version deployments))

(struct deployment (uid name replicas))

(define (item->deployment item)
  (let* ([metadata (hash-ref item 'metadata)]
	 [spec (hash-ref item 'spec)]
	 [uid (hash-ref metadata 'uid)]
	 [name (hash-ref metadata 'name)]
	 [replicas (hash-ref spec 'replicas)])
    (deployment uid name replicas)))

(define (add-deployment item deployments)
  (let* ([deployment (item->deployment item)])
    (hash-set! deployments (deployment-uid deployment) deployment)
    deployments))

(define (items->deployments items)
  (foldl add-deployment (make-hash) items))

(define (get-state url)
  (let* ([doc (get-json url)]
         [metadata (hash-ref doc 'metadata)]
         [resource-version (hash-ref metadata 'resourceVersion)]
         [items (hash-ref doc 'items)])
    (state resource-version (items->deployments items))))

(define (make-watcher out namespace)
  (let* ([url (make-url namespace)]
         [state (get-state url)])
    (thread
     (lambda ()
       (let loop ()
         (thread-send out (state-resource-version state))
         (loop))))))
