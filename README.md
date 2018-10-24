predicate-lambda - an implementation of full predicate dispatch for 
R6RS Scheme.

The proposed predicate dispatch model is similar to the defgeneric/defmethod system in CLOS, but simpler and with lower ceremony. It is also similar to case-lambda.

A procedure defined with *predicate-lambda* will test argument lists passed to it against a series of matching predicates. This is similar to the way in which case-lambda acts, except that in addition to comparing the arity of the dispatchable arguments to the number of arguments, it may perform one or more comparisons on the values of the arguments, and accept or reject a given argument list on those comparisons.

The general form of *predicate-lambda* is any of the following

    (predicate-lambda
      (guard (<guard-predicate-0>
             ...
             (guard (<guard-predicate-n>
                    (((<param-predicates-0>) (<body-0>)) 
                     (assure 
                       (<assurance-0> <assurance-cond-0>)
                       ...
                       (<assurance-n> <assurance-cond-n>) 
                       unassured <unassured-cond>)
                    ...
                    ((<param-predicates-n>) (<body-n>)))))
             else <guard-condition-n>)
             ...
      else <guard-condition-0>)
      (assure 
        (<global-assurance-0> <global-assurance-cond-0>)
        ...
        (<global-assurance-n> <global-assurance-cond-n>) 
        unassured <global-unassured-condition>)


The *guard* clause allows for a predicate which apply to classes of input values, above and beyond the specific predicates for the dispatchable procedures. Any argument list that doesn't match all predicate tests in at least one group of guards will fail. Guard clauses may be inserted recursively, to allows for drill-down in defining the predicates. For a simple dispatch with no overall classes of arguments, the *guard* and it's predicate may be omitted.

If no match is found, a condition code is raised. The default for this shall be *&unmatched-predicate-arguments-condition*, but a custom condition may be set optionally with the *else* clause.

The *assure* clauses, both for individual procedures and for the procedure as a whole, allows to function to enforce post-conditions. Each assurance may have an optional condition specific to it, and the assurance clause as whole may have a condition; otherwise, the default *&failed-assurance-condition* is raised.

The usable forms for a parameter predicate are

    (<param-0> ... <param-n> [ . <rest-params>]) 

This is equivalent to the parameter list of a *case-lambda* form.

    ((<param-0> ... <param-n> [ . <rest-params>]) (<pred-0> ... <pred-n>))

This form pairs the parameter list with a set of one or more predicates to match the parameters with.

Implicit matching to constant parameters is a shorthand that allows a function to be matched to that constant, without needing and express predicate comparison. The *(range* **x** **y**)* clause allows a [*x*, *y*) range of values where *x* and *y* are both of the same simple scalar (integer, character, or enum) or representable real (rational, fixnum, flonum) type. 
`
For example, let's take the conventional recursive form of Fibonacci, 

    (define (fib n)
      (cond ((not (and (integer? n) (positive? n))) 0)
            ((= 0 n) 0)
            ((= 1 n) 1)
            (else (* n (fib (- n 1))))))

This can be simply re-written using *predicate-lambda* as

    (define (fib n)
      (predicate-lambda
        (= 0 n) 0)
        ((= 1 n) 1)
        (((n) (and (integer? n) (positive? n))) (fib (- n 1)))

This, too, should give the expected results for the Fibonacci function. While this shows few obvious advantages over the previous form, it does have the immediate effect that it now will throw a default error when out of bounds.

We can simplfy this slightly with implicit constant matching:

    (define (fib n)
      (predicate-lambda
        (0 0)
        (1 1)
        (((n) (and (integer? n) (positive? n))) (fib (- n 1)))

The similarity in this example to the model of type dispatch in Haskell should be readily apparent. However, we can further use a pair of *guard* clauses to enforce error handling: 

    (define fib
      (predicate-lambda
        (guard (integer? n) 
          (guard (positive? n)
            (0 0)
            (1 1)
            ((n) (* n (fib (- n 1))))
          (else &fib-type-mismatch-condition)))
        (else &fib-input-out-of-bounds-condition)
        (assure integer?)))

If we don't need to identify the cause of the failed match, we could have written it as:

    (define fib
      (predicate-lambda
        (guards ((integer? n) (positive? n))
          (0 0)
          (1 1)
          ((n) (* n (fib (- n 1)))))))



    (define foo
      (predicate-lambda 
        ((


An additional form,  or *define-with-multiple-dispatch* (aliased to *define/md*), allows a function to be defined with *predicate-lambda* (or using a shorthand *define* syntax) in a manner that not only dispatched dynamically, but can be extended with additional *define/md* definitions.
