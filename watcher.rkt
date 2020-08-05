#lang racket

(require lens
	 threading
	 unstable/lens)

(require "utils.rkt")

(provide make-watcher)

; URLS
(define deployments-url "http://localhost:5555/apis/apps/v1/namespaces/~a/deployments")

(define (namespace-url namespace)
  (format deployments-url namespace))

(define (watch-url url resource-version)
  (string-append url "?watch=1&resourceVersion=" resource-version))

; LENSES
(define resource-version-lens
  (hash-ref-nested-lens 'metadata 'resourceVersion))

(define object-resource-version-lens
  (hash-ref-nested-lens 'object 'metadata 'resourceVersion))

(define uid-lens
  (lens-thrush (hash-ref-lens 'metadata)
	       (hash-ref-lens 'uid)))

(define metadata-lens
  (lens-thrush (hash-ref-lens 'metadata)
	       (hash-pick-lens 'name 'uid)))

(define spec-lens
  (lens-thrush (hash-ref-lens 'spec)
	       (hash-pick-lens 'replicas)))

(define status-lens
  (lens-thrush (hash-ref-lens 'status)
	       (hash-pick-lens 'replicas 'availableReplicas 'readyReplicas)))

(define deployment-lens
  (lens-join/hash 'metadata metadata-lens
		  'spec spec-lens
		  'status status-lens))

(define deployments-lens
  (lens-thrush (hash-ref-lens 'items)
	       (map-lens deployment-lens)))

(define type-lens
  (hash-ref-lens 'type))

(define object-deployment-lens
  (lens-thrush (hash-ref-lens 'object)
	       deployment-lens))

; GET DATA
(define (get-data namespace)
  (~> namespace
      namespace-url
      get-json))

(define (watch-data namespace resource-version)
  (~> namespace
      namespace-url
      (watch-url resource-version)
      get-json))

; TRANSFORM DATA
(struct State (resource-version deployments))
(struct Update (resource-version deployment))

(define (set-uid item hash)
  (hash-set! hash (lens-view uid-lens item) item)
  hash)

(define (deployments-hash deployments)
  (foldl set-uid (make-hash) deployments))

(define (reducer state update)
  (State (Update-resource-version update)
	 (set-uid (Update-deployment update) (State-deployments state))))

(define (get-first-state namespace)
  (let ([data (get-data namespace)])
    (State (lens-view resource-version-lens data)
	   (deployments-hash (lens-view deployments-lens data)))))

(define (get-watch-state namespace resource-version)
  (let ([data (watch-data namespace resource-version)])
    (Update (lens-view object-resource-version-lens data)
	    (lens-view object-deployment-lens data))))

; EXPORTS
(define (make-watcher out namespace)
  (thread
   (lambda ()
     (let loop ([state (get-first-state namespace)])
       (sleep 1)
       (displayln (State-deployments state))
       (~>> (get-watch-state namespace (State-resource-version state))
	    (reducer state)
	    ; ((lambda (s) (thread-send out (State-deployments s)) s))
	    (loop))))))
