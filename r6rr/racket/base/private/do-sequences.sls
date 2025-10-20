#!r6rs

(library (r6rr racket base private do-sequences)
  (export :init-pos
          :continue-with-pos?
          :pos->element
          :continue-with-val?
          :early-next-pos
          :continue-after-pos+val?
          :next-pos
          make-do-sequence
          do-sequence?
          initiate-sequence
          do-sequence-generate
          do-sequence-generate*)
  (import (rnrs base (6))
          (rnrs conditions (6))
          (rnrs control (6))
          (rnrs exceptions (6))
          (rnrs records syntactic (6))
          (r6rr racket base private contracts)
          (r6rr racket base private error)
          (r6rr racket base private exceptions)
          (r6rr racket base private lambda)
          (r6rr racket undefined))

  (define :init-pos undefined)
  (define :continue-with-pos? undefined)
  (define :pos->element undefined)
  (define :continue-with-val? undefined)
  (define :early-next-pos undefined)
  (define :continue-after-pos+val? undefined)
  (define :next-pos undefined)

  (define (raise-sequence-empty-error)
    (raise-exn make-exn:fail:contract "sequence has no more values"))

  (define-record-type do-sequence (fields thunk))
  (define-syntax initiate-sequence
    (syntax-rules (:init-pos
                   :continue-with-pos?
                   :pos->element
                   :continue-with-val?
                   :early-next-pos
                   :continue-after-pos+val?
                   :next-pos)
      [(_ :init-pos init-pos
          :continue-with-pos? continue-with-pos?
          :pos->element pos->element
          :continue-with-val? continue-with-val?
          :early-next-pos early-next-pos
          :continue-after-pos+val? continue-after-pos+val?
          :next-pos next-pos)
       (values pos->element
               early-next-pos
               next-pos
               init-pos
               continue-with-pos?
               continue-with-val?
               continue-after-pos+val?)]

      [(_ :init-pos init-pos
          :pos->element pos->element
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? #f
        :pos->element pos->element
        :continue-with-val? #f
        :early-next-pos #f
        :continue-after-pos+val? #f
        :next-pos next-pos)]

      [(_ :init-pos init-pos
          :continue-with-pos? continue-with-pos?
          :pos->element pos->element
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? continue-with-pos?
        :pos->element pos->element
        :continue-with-val? #f
        :early-next-pos #f
        :continue-after-pos+val? #f
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :pos->element pos->element
          :continue-with-val? continue-with-val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? #f
        :pos->element pos->element
        :continue-with-val? continue-with-val?
        :early-next-pos #f
        :continue-after-pos+val? #f
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :pos->element pos->element
          :early-next-pos early-next-pos
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? #f
        :pos->element pos->element
        :continue-with-val? #f
        :early-next-pos early-next-pos
        :continue-after-pos+val? #f
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :pos->element pos->element
          :continue-after-pos+val? continue-after-pos+val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? #f
        :pos->element pos->element
        :continue-with-val? #f
        :early-next-pos #f
        :continue-after-pos+val? continue-after-pos+val?
        :next-pos next-pos)]

      [(_ :init-pos init-pos
          :pos->element pos->element
          :early-next-pos early-next-pos
          :continue-after-pos+val? continue-after-pos+val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? #f
        :pos->element pos->element
        :continue-with-val? #f
        :early-next-pos early-next-pos
        :continue-after-pos+val? continue-after-pos+val?
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :pos->element pos->element
          :continue-with-val? continue-with-val?
          :continue-after-pos+val? continue-after-pos+val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? #f
        :pos->element pos->element
        :continue-with-val? continue-with-val?
        :early-next-pos #f
        :continue-after-pos+val? continue-after-pos+val?
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :pos->element pos->element
          :continue-with-val? continue-with-val?
          :early-next-pos early-next-pos
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? #f
        :pos->element pos->element
        :continue-with-val? continue-with-val?
        :early-next-pos early-next-pos
        :continue-after-pos+val? #f
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :continue-with-pos? continue-with-pos?
          :pos->element pos->element
          :continue-after-pos+val? continue-after-pos+val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? continue-with-pos?
        :pos->element pos->element
        :continue-with-val? #f
        :early-next-pos #f
        :continue-after-pos+val? continue-after-pos+val?
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :continue-with-pos? continue-with-pos?
          :pos->element pos->element
          :early-next-pos early-next-pos
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? continue-with-pos?
        :pos->element pos->element
        :continue-with-val? #f
        :early-next-pos early-next-pos
        :continue-after-pos+val? #f
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :continue-with-pos? continue-with-pos?
          :pos->element pos->element
          :continue-with-val? continue-with-val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? continue-with-pos?
        :pos->element pos->element
        :continue-with-val? continue-with-val?
        :early-next-pos #f
        :continue-after-pos+val? #f
        :next-pos next-pos)]

      [(_ :init-pos init-pos
          :pos->element pos->element
          :continue-with-val? continue-with-val?
          :early-next-pos early-next-pos
          :continue-after-pos+val? continue-after-pos+val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? #f
        :pos->element pos->element
        :continue-with-val? continue-with-val?
        :early-next-pos early-next-pos
        :continue-after-pos+val? continue-after-pos+val?
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :continue-with-pos? continue-with-pos?
          :pos->element pos->element
          :early-next-pos early-next-pos
          :continue-after-pos+val? continue-after-pos+val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? continue-with-pos?
        :pos->element pos->element
        :continue-with-val? #f
        :early-next-pos early-next-pos
        :continue-after-pos+val? continue-after-pos+val?
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :continue-with-pos? continue-with-pos?
          :pos->element pos->element
          :continue-with-val? continue-with-val?
          :continue-after-pos+val? continue-after-pos+val?
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? continue-with-pos?
        :pos->element pos->element
        :continue-with-val? continue-with-val?
        :early-next-pos #f
        :continue-after-pos+val? continue-after-pos+val?
        :next-pos next-pos)]
      [(_ :init-pos init-pos
          :continue-with-pos? continue-with-pos?
          :pos->element pos->element
          :continue-with-val? continue-with-val?
          :early-next-pos early-next-pos
          :next-pos next-pos)
       (initiate-sequence
        :init-pos init-pos
        :continue-with-pos? continue-with-pos?
        :pos->element pos->element
        :continue-with-val? continue-with-val?
        :early-next-pos early-next-pos
        :continue-after-pos+val? #f
        :next-pos next-pos)]))

  (define (do-sequence-generate seq)
    (unless (do-sequence? seq)
      (raise-argument-error 'do-sequence-generate "do-sequence?" seq))
    (let ([vals #f] [next (λ () (do-sequence-generate* seq))])
      (define (more?)
        (or (not (not vals))
            (let-values ([(vals1 next1) (next)])
              (set! vals vals1)
              (set! next next1)
              (not (not vals1)))))
      (define (get)
        (unless (more?)
          (raise-sequence-empty-error))
        (let ([val* vals])
          (set! vals #f)
          (apply values val*)))
      (values more? get)))
  (define (do-sequence-generate* seq)
    (unless (do-sequence? seq)
      (raise-argument-error 'do-sequence-generate* "do-sequence?" seq))
    (let*-values ([(pos->element
                    early-next-pos
                    next-pos
                    init-pos
                    continue-with-pos?
                    continue-with-val?
                    continue-after-pos+val?)
                   ((do-sequence-thunk seq))])
      (let ([early-next-pos (or early-next-pos values)]
            [continue-with-pos? (or continue-with-pos? any)]
            [continue-with-val? (or continue-with-val? any)]
            [continue-after-pos+val? (or continue-after-pos+val? any)])
        (let loop ([pos init-pos])
          (if (continue-with-pos? pos)
              (let-values ([val* (pos->element pos)])
                (if (apply continue-with-val? val*)
                    (let ([pos (early-next-pos pos)])
                      (if (apply continue-after-pos+val? pos val*)
                          (let ([pos (next-pos pos)])
                            (values val* (λ () (loop pos))))
                          (values #f raise-sequence-empty-error)))
                    (values #f raise-sequence-empty-error)))
              (values #f raise-sequence-empty-error)))))))
