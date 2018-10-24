#!r6rs

(library (predicate-dispatch)
  (export predicate-lambda
          define-with-dispatch-predicates define/dp)
  
  (import (rnrs base (6))
          (rnrs hashtables (6))
          (rnrs control (6)))   ; for case-lambda
          
  (define-syntax predicate-lambda
    