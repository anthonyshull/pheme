#lang racket

(require lens
	 loop
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

(define metadata-lens
  (lens-thrush (hash-ref-lens 'metadata)
	       (hash-pick-lens 'name 'uid)))

(define spec-lens
  (lens-thrush (hash-ref-lens 'spec)
	       (hash-pick-lens 'replicas)))

(define status-lens
  (lens-thrush (hash-ref-lens 'status)
	       (hash-pick-lens 'replicas)))

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
(struct state (resource-version deployments))
(strict update (resource-version deployment))

(define (reducer state update)
  )

(define (get-first-state namesace)
  (let ([data (get-data namespace)])
    (state (lens-view resource-version-lens data)
	   (lens-view deployments-lens data))))

; EXPORTS
(define (make-watcher out namespace)
  (loop watch ([s (get-first-state namespace)])
	(~>> (watch-data namespace (state-resource-version s))
	     (reducer s)
	     (watch))))
