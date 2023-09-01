#lang racket
(require racket/base)

(define input-path "files-cover/zombie-combined-all.rkt")
(define output-path-base "files-cover/run-test-")
; run-test-1, run-test-2, etc etc

(define input (open-input-file input-path))
(port-count-lines! input)

(define size 2288)
(define lines (make-vector size ""))
(define tests (make-hash)) ; maps line numbers to tests

(for ([i (in-range 1 size)])
  ;(println i)
  (define line (read-line input))
  (if (string? line)
      (if (< (string-length line) 10)
          (vector-set! lines (- i 1) line)
          (if (string=? "(run-tests" (substring line 0 10))
              (hash-set! tests i line)
              (vector-set! lines (- i 1) line)))
      (vector-set! lines (- i 1) line))
  ;(println line)
  )

;(println lines)
;(println tests)
(println (length (hash-keys tests)))

(close-input-port input)

(define cover-cmd (open-output-file "files-cover/cover-cmd.txt" #:exists 'replace))
(display "raco cover -d coverage " cover-cmd)

;(define output (open-output-file "files-cover/test-output.rkt" 'binary 'replace #o666 #f))
(for ([i (hash-keys tests)])
  (define output-path (string-append output-path-base (~a i) ".rkt"))
  ;(write (string-append (string #\") output-path (string #\")) cover-cmd)
  ;(writeln output-path cover-cmd)
  ;(fprintf cover-cmd (string-append "\"" output-path "\" "))
  (display (string-append "\"" output-path "\" ") cover-cmd)
  (define output (open-output-file output-path #:exists 'replace))
  (for ([line lines])
    ;(writeln line output)
    ;(fprintf output (string-append line "\n"))
    ;(println line)
    (if (string? line)
        (display (string-append line "\n") output)
        (println "not a string"))
    )
  (display (string-append (hash-ref tests i) "\n") output)
  (close-output-port output)
  )

(close-output-port cover-cmd)
