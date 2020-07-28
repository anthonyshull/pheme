#lang racket

(require json
	 lens
         net/url
	 unstable/lens)

(provide make-watcher)

(define (make-url namespace)
  (format "http://localhost:8888/apis/apps/v1/namespaces/~a/deployments" namespace))

(define (make-watch-url url resource-version)
  (format "~a?watch=1&resourceVersion=~a" url resource-version))

(define (get-json url)
   (call/input-url (string->url url)
                   get-pure-port
                   read-json))

(define resource-version-lens
  (hash-ref-nested-lens 'metadata 'resourceVersion))

(define metadata-lens
  (lens-thrush (hash-ref-lens 'metadata)
	       (hash-pick-lens 'name 'uid)))

(define status-lens
  (lens-thrush (hash-ref-lens 'status)
	       (hash-pick-lens 'replicas)))

(define deployment-lens
  (lens-join/hash 'metadata metadata-lens
		  'status status-lens))

(define items-lens
  (lens-thrush (hash-ref-lens 'items)
	       (map-lens deployment-lens)))

(define (make-watcher out namespace)
  (let* ()
    (thread
     (lambda ()
       (let loop ()
         (thread-send out '())
         (loop))))))
