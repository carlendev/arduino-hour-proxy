#lang racket

(require (planet dmac/spin)
	 web-server/servlet
	 json)

(define (json-404-response-maker status headers body)
  (response status
	    (status->message status)
	    (current-seconds)
	    #"application/json; charset=utf-8"
	    headers
	    (let ([jsexpr-body (case status
				 [(404) (string->jsexpr
					 "{\"error\": 404, \"message\": \"Not Found\"}")]
				 [else body])])
	      (lambda (op) (write-json (force jsexpr-body) op)))))

(define (json-response-maker status headers body)
  (response status
	    (status->message status)
	    (current-seconds)
	    #"application/json; charset=utf-8"
	    headers
	    (let ([jsexpr-body (string->jsexpr body)])
	      (lambda (op) (write-json (force jsexpr-body) op)))))

(define (json-get path handler)
  (define-handler "GET" path handler json-response-maker))

(json-get "/json" (lambda (req)
		    "{\"body\":\"OK\"}"))

(post "/json" (lambda (req)
		(define body-pairs
		  (match (request-post-data/raw req)
		    [#f empty]
		    [body (bytes->string/utf-8 body)]))
      body-pairs))

(run #:port 8080 #:response-maker json-404-response-maker)
