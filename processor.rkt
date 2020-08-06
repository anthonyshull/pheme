#lang racket

(require threading)

(provide make-processor)

(define (make-processor out)
  (thread
   (lambda ()
     (let loop ()
       (sleep 0.5)
       (~>> (thread-receive)
	    ;; process
	    ;; send to next thread
	    ;; ((lambda (s) (displayln s) s))
	    (thread-send out))
       (loop)))))
