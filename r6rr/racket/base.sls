#!r6rs

(library (r6rr racket base)
  (export
   ;; contracts
   false?
   true?
   and/c
   or/c
   not/c
   any/c
   none/c
   =/c
   </c
   >/c
   <=/c
   >=/c

   ;; control
   let/cc
   current-continuation cc

   ;; define
   define-syntax-rule

   ;; do-sequences
   :init-pos
   :continue-with-pos?
   :pos->element
   :continue-with-val?
   :early-next-pos
   :continue-after-pos+val?
   :next-pos
   make-do-sequence
   do-sequence?
   do-sequence-generate
   do-sequence-generate*
   initiate-sequence

   ;; error
   unquoted-printing-string?
   unquoted-printing-string
   make-unquoted-printing-string
   unquoted-printing-string-value
   raise-user-error
   raise-argument-error
   raise-result-error
   raise-arguments-error
   raise-range-error

   ;; exceptions
   call-with-exception-handler
   with-handlers
   with-handlers*
   &exn make-exn exn?
   exn-message
   &exn:fail make-exn:fail exn:fail?
   &exn:fail:contract make-exn:fail:contract exn:fail:contract?
   &exn:fail:user make-exn:fail:user exn:fail:user?

   ;; TODO for
   :result :length :fill
   :when :unless :do
   :break :final
   for/foldl for*/foldl
   ;; for/void for*/void
   ;; for for*
   ;; for/list for*/list
   ;; for/vector for*/vector
   ;; for/hash for*/hash
   ;; for/and for*/and
   ;; for/or for*/or
   ;; for/first for*/first
   ;; for/last for*/last
   ;; for/sum for*/sum
   ;; for/product for*/product

   ;; TODO function
   ;; compose
   ;; compose1
   ;; ∘
   ;; ∘₁

   ;; lambda
   λ
   case-λ
   identity

   ;; lists
   andmap
   ormap

   ;; math
   add1
   sub1
   exact-integer?
   exact-nonnegative-integer?
   natural?

   ;; print
   displayln
   writeln
   fprintf
   printf
   eprintf

   ;; sequences
   define-sequence
   sequence?
   sequence-generate
   sequence-generate*
   in-naturals
   in-values
   in-range
   in-inclusive-range
   in-string
   in-vector
   in-bytevector
   in-list*
   in-hashtable
   in-port

   ;; format
   format ~a ~s

   ;; void
   void
   void?)
  (import (r6rr racket base private contracts)
          (r6rr racket base private control)
          (r6rr racket base private define)
          (r6rr racket base private do-sequences)
          (r6rr racket base private error)
          (r6rr racket base private exceptions)
          (r6rr racket base private for)
          ;; (r6rr racket base private functions)
          (r6rr racket base private lambda)
          (r6rr racket base private lists)
          (r6rr racket base private math)
          (r6rr racket base private print)
          (r6rr racket base private sequences)
          (r6rr racket base private format)
          (r6rr racket base private void)))
