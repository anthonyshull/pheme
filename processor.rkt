#lang racket

(require threading)

(provide make-processor)

(define (tablify-helper table uids data)
  (cond [(hash? data)
	 (let ([keys (hash-keys data)])
	   (if (empty? keys)
	       '()
	       (let ([key (first keys)])
		 (append
		  (tablify-helper table (append uids (list key)) (hash-ref data key))
		  (tablify-helper table uids (hash-remove data key))))))]
	[(integer? data)
	 (cons (list (string-join (map symbol->string uids) ".") data) table)]
	[else
	 table]))

(define (tablify data)
  (tablify-helper '() '() data))

(define (plus-minus a b)
  (cond
   [(= a b) "="]
   [(> b a) "+"]
   [(< b a) "-"]))

(define (diff left-right)
  (let ([olds (tablify (first left-right))]
	[news (tablify (second left-right))])
    (for/list ([old olds]
	       [new news]
	       #:when (equal? (first old) (first new)))
      (list (hash-ref (hash-ref (first left-right) 'metadata) 'uid)
	    (first old)
	    (plus-minus (second old) (second new))
	    (abs (- (second old) (second new)))))))

(define (make-processor out)
  (thread
   (lambda ()
     (let loop ()
       (~>> (thread-receive)
	    (diff)
	    (thread-send out))
       (loop)))))
