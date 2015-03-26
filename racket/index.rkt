#lang racket

(require json)

; Make namespace
; http://stackoverflow.com/questions/20778926/mysterious-racket-error-define-unbound-identifier-also-no-app-syntax-trans
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))

; Structure definition
(struct user (first-name last-name password))

; Struct to jsexpr converter
(define (user->jsexpr user)
  (hasheq 'first-name (user-first-name user)
          'last-name (user-last-name user)
          'password (user-password user)))

; List of structs converter to jsexpr
(define list:struct->jsexpr
    (lambda (struct-type lst)
        (define string->proc
            (lambda (x) ((eval (read (open-input-string (string-append struct-type
                                                                       "->jsexpr")))
                                ns) x)))
        (map string->proc lst)))

; List of struct converter to jsexpr
(define list:jsexpr->struct
    (lambda (struct-type lst)
        (define string->proc
            (lambda (x) ((eval (read (open-input-string (string-append "jsexpr->"
                                                                       struct-type)))
                                ns) x)))
        (map string->proc lst)))

; Struct to jsexpr converter
(define (jsexpr->user my-hash)
  (hash-values my-hash))

; Create a list of user structs
(define lst (list (user "Jose" "Flores" "mypassword")
                  (user "Amanda" "Flores" "herPassword")))

; Define output file
(define out (open-output-file "output.json"
                              #:exists 'replace))
; Write JSON to file
(write-json (list:struct->jsexpr "user" lst) out)

; Close output file
(close-output-port out)

; Define input file
(define in (open-input-file "output.json"))

; Read JSON from file and translate to a list of structs
(list:jsexpr->struct "user" (read-json in))

; Close input file
(close-input-port in)
