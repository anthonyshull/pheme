#lang racket

(require threading)

(provide make-processor)

(define (make-processor out)
  (thread
   (lambda ()
     (let loop ()
       (~>> (thread-receive)
            ; compute diff & send to publisher
            (thread-send out)
            (loop))))))