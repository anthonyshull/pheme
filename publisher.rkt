#lang racket

(require json
         net/rfc6455
	 racket/port)

(provide make-publisher)

(define (make-publisher)
  (thread
   (lambda ()
     (let loop ([subscribers (list)])
       (match (thread-receive)
         [(? ws-conn? conn)
	  (loop (cons conn subscribers))]
         [(? jsexpr? json)
	  (for-each (lambda (conn) (ws-send! conn (with-output-to-string (lambda () (write-json json)))))
		    subscribers)
	  (loop subscribers)])))))
