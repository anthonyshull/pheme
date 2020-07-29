#lang racket

(require json
	 net/url)

(provide get-json)

(define (get-json url)
   (call/input-url (string->url url)
                   get-pure-port
                   read-json))

