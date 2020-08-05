#lang racket

(require json
         net/rfc6455)

(provide make-publisher)

(define (make-publisher)
  (let ([subscribers (list)])
    (thread
     (lambda ()
       (let loop ()
         (match (thread-receive)
           ; add subscriber
           [(? ws-conn? conn)
            (append subscribers conn)
            (loop)]
           ; send message to all subscribers
           [(? jsexpr? json)
            (for ([conn subscribers])
              (ws-send! conn json))
            (loop)]))))))
