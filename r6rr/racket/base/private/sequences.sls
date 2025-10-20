#!r6rs

(library (r6rr racket base private sequences)
  (export define-sequence
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
          in-port)
  (import (rnrs base (6))
          (rnrs bytevectors (6))
          (rnrs conditions (6))
          (rnrs control (6))
          (rnrs exceptions (6))
          (rnrs hashtables (6))
          (rnrs io ports (6))
          (rnrs io simple (6))
          (rnrs mutable-pairs (6))
          (r6rr racket base private contracts)
          (r6rr racket base private do-sequences)
          (r6rr racket base private error)
          (r6rr racket base private exceptions)
          (r6rr racket base private lambda)
          (r6rr racket base private math)
          (r6rr racket undefined))

  (define (list->values v*) (apply values v*))
  (define (list*? l) (or (null? l) (pair? l)))

  (define table `([,do-sequence? . ,values]))
  (define sequence-queue (cons table table))
  (define (define-sequence seq? in-seq)
    (let ([end (cdr sequence-queue)]
          [table `([,seq? . ,in-seq])])
      (set-cdr! end table)
      (set-cdr! sequence-queue table)))

  (define (sequence? seq)
    (let loop ([table table])
      (and (pair? table)
           (or ((caar table) seq)
               (loop (cdr table))))))
  (define (sequence->do-sequence seq)
    (let loop ([table table])
      (when (null? table)
        (raise-argument-error 'sequence->do-sequence "sequence?" seq))
      (let ([p (car table)])
        (or (and ((car p) seq)
                 ((cdr p) seq))
            (loop (cdr table))))))

  (define (sequence-generate seq)
    (unless (sequence? seq)
      (raise-argument-error 'sequence-generate "sequence?" seq))
    (do-sequence-generate (sequence->do-sequence seq)))
  (define (sequence-generate* seq)
    (unless (sequence? seq)
      (raise-argument-error 'sequence-generate "sequence?" seq))
    (do-sequence-generate* (sequence->do-sequence seq)))

  (define in-naturals
    (λ ([start 0])
      (make-do-sequence
       (λ ()
         (initiate-sequence
          :init-pos start
          :pos->element values
          :next-pos add1)))))
  (define (in-values . v*)
    (make-do-sequence
     (λ ()
       (define first? #t)
       (define (continue-with-pos? _)
         (and first? (begin (set! first? #f) #t)))
       (initiate-sequence
       :init-pos v*
       :continue-with-pos? continue-with-pos?
       :pos->element list->values
       :next-pos values))))

  (define (make-in-range who >? <?)
    (define (in-range start end step)
      (unless (real? start)
        (raise-argument-error who "real?" start))
      (unless (real? end)
        (raise-argument-error who "real?" end))
      (unless (real? step)
        (raise-argument-error who "real?" step))
      (let ([next-pos (λ (pos) (+ pos step))]
            [continue-with-pos?
             (if (< step 0)
                 (λ (pos) (>? pos end))
                 (λ (pos) (<? pos end)))])
        (make-do-sequence
         (λ ()
           (initiate-sequence
            :init-pos start
            :continue-with-pos? continue-with-pos?
            :pos->element values
            :next-pos next-pos)))))
    (case-λ
      [(end) (in-range 0 end 1)]
      [(start end) (in-range start end 1)]
      [(start end step) (in-range start end step)]))
  (define in-range (make-in-range 'in-range > <))
  (define in-inclusive-range (make-in-range 'in-inclusive-range >= <=))

  (define (in-list* l)
    (make-do-sequence
     (λ ()
       (initiate-sequence
        :init-pos l
        :continue-with-pos? pair?
        :pos->element car
        :next-pos cdr))))

  (define (make-in-vec who expected vec? vec-ref vec-length)
    (define (in-vec vec start stop step)
      (unless (vec? vec)
        (raise-argument-error who expected vec))
      (unless (real? start)
        (raise-argument-error who "real?" start))
      (unless (real? stop)
        (raise-argument-error who "real?" stop))
      (unless (real? step)
        (raise-argument-error who "real?" step))
      (let ([stop (or stop (vec-length vec))])
        (make-do-sequence
         (λ ()
           (initiate-sequence
            :init-pos start
            :continue-with-pos?
            (if (< step 0)
                (λ (pos) (> pos stop))
                (λ (pos) (< pos stop)))
            :pos->element (λ (pos) (vec-ref vec pos))
            :next-pos (λ (pos) (+ pos step)))))))
    (case-λ
      [(vec) (in-vec vec 0 (vec-length vec) 1)]
      [(vec start) (in-vec vec start (vec-length vec) 1)]
      [(vec start stop) (in-vec vec start stop 1)]
      [(vec start stop step) (in-vec vec start stop step)]))
  (define in-string (make-in-vec 'in-string "string?" string? string-ref string-length))
  (define in-vector (make-in-vec 'in-vector "vector?" vector? vector-ref vector-length))
  (define in-bytevector (make-in-vec 'in-bytevector "bytevector?" bytevector? bytevector-u8-ref bytevector-length))

  (define (in-hashtable ht)
    (unless (hashtable? ht)
      (raise-argument-error 'in-hashtable "hashtable?" ht))
    (let-values ([(k* v*) (hashtable-entries ht)])
      (make-do-sequence
       (λ ()
         (initiate-sequence
          :init-pos 0
          :continue-with-pos? (</c (vector-length k*))
          :pos->element (λ (pos) (values (vector-ref k* pos) (vector-ref v* pos)))
          :next-pos add1)))))

  (define in-port
    (λ ([r read] [in (current-input-port)])
      (unless (procedure? r)
        (raise-argument-error 'in-port "procedure?" r))
      (unless (input-port? in)
        (raise-argument-error 'in-port "input-port?" in))
      (make-do-sequence
       (λ ()
         (initiate-sequence
          :init-pos in
          :continue-with-pos? (not/c port-eof?)
          :pos->element r
          :next-pos values)))))
  (define (port->sequence in) (in-port read in))

  (define-sequence natural? in-range)
  (define-sequence string? in-string)
  (define-sequence vector? in-vector)
  (define-sequence bytevector? in-bytevector)
  (define-sequence list*? in-list*)
  (define-sequence hashtable? in-hashtable)
  (define-sequence input-port? port->sequence))
