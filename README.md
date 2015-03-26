# Final Project Assignment 2: Explore One More! (FP2) 
DUE March 30, 2015 Monday (2015-03-30)

## My Library: json

### Narrative
Since I worked with the webserver library last and can make webpages and in turn possibly an API, it would be a good idea to be able to generate and read data in JSON. I first looked at the JSON library and tried creating a simple element as a JSON string and once I saw how it worked I moved on to structures.

I created a simple structure that would describe a user and using the JSON library I created a structure to jsexpr generating procedure. Once this was done I was able to output the JSON of the structure to the screen. I then thought to extend this by making a procedure that would apply this to a list of structures. Having the JSON display to the terminal was fine but, I wanted to output it to a file. Doing this taught me how to open output files and close them in the process.

At this point I had gotten data from Racket to a JSON file that could be used by other services. I then implemented the reverse to be able to read JSON, in turn learning how to read from files and displaying the output. I noticed that the output differed from the original input, returning jsexpr rather than the list of structures and worked on created a backwards conversion to get the original data, learning how to use hash-values to convert back.

Once it all worked I then wrote a function that would convert list of hashes back to the original format of lists of structures. I then generalized this function to be able to work for any structure. This gave me some trouble as eval requires a namespace and I didnt realize it, the article on [www.stackoverflow.com][stack] helped me figure it out. Now I can create JSON from a list of structures and vice versa. This gives me a head start in being able to create a Racket web API.

### Source Code
```
#lang racket

(require json)

; Make namespace
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
```
### Output 
#### Write output
This output was written to output.json
```
[{"first-name":"Jose","last-name":"Flores","password":"mypassword"},{"first-name":"Amanda","last-name":"Flores","password":"herPassword"}]
```
#### Read output
This output was to the screen from the file output.json.
```
'(("Jose" "Flores" "mypassword") ("Amanda" "Flores" "herPassword"))
```

<!-- Links -->
[stack]:http://stackoverflow.com/questions/20778926/mysterious-racket-error-define-unbound-identifier-also-no-app-syntax-trans
