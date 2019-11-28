#lang scribble/doc
@require[scribble/manual
         scribble-abbrevs/manual
         scribble/example
		 racket/sandbox
         @for-label[relation/comparable
                    relation/transform
		            racket/generic
                    (except-in racket < <= = >= > min max)]]

@title{Order and Equivalence Relations}

@defmodule[relation/comparable]

A generic interface for comparing data. By default, the built-in comparison operators @racket[<], @racket[<=], @racket[=], @racket[>=] and @racket[>] operate on @tech/reference{numbers} specifically, while other comparable types like characters and strings have their own type-specific comparison operators, for instance @racket[char<?] and @racket[string<?]. This module provides a generic interface that overrides these standard operators to allow their use for any comparable type and not only numbers, and also provides additional interfaces to support broader notions of equivalence than simple equality. You can also provide an implementation for the interface in custom types so that they can be compared using the same standard operators.

@(define eval-for-docs
  (parameterize ([sandbox-output 'string]
                 [sandbox-error-output 'string]
                 [sandbox-memory-limit #f])
                 (make-evaluator 'racket/base
				                 '(require relation)
				                 '(require racket/function)
								 '(require racket/set))))

@defthing[gen:comparable any/c]{

 A @tech/reference{generic interface} that represents any object that can be compared with other objects of the same type in terms of equivalence ("are these values equal, for some definition of equality?") and order ("is this value less than or greater than that value?"). All built-in types have a default implementation for @racket[gen:comparable], however, most of them implement only the equivalence relations, while a few support the order relations as well. Specifically, the following built-in types have implementations for the order relations @racket[<], @racket[<=], @racket[>=] and @racket[>] in addition to the equivalence relations @racket[=] and @racket[/=]:

@itemlist[
 @item{@tech/reference{numbers}}
 @item{@tech/reference{strings}}
 @item{@tech/reference{byte strings}}
 @item{@tech/reference{characters}}
 @item{@tech/reference{sets}}]

Note that even if a type implements the order relations, some values may still be order-incomparable (see @hyperlink["https://en.wikipedia.org/wiki/Partially_ordered_set"]{partial order}), meaning that none of the relations would return true for them. For instance, the sets {1, 2} and {1, 3} are incomparable under their canonical order relation (i.e. @racket[subset?]), while also not being equal.

@examples[
    #:eval eval-for-docs
    (< 1 2 3)
    (> #\c #\b #\a)
    (< "apple" "banana" "cherry")
    (< (set) (set 1) (set 1 2))
    (= "apple" "APPLE")
    (= #:key string-upcase "apple" "APPLE")
    (= #:key ->number "42.0" "42/1")
  ]
}

@defproc[(< [v comparable?] ...)
         boolean?]{

 True if the v's are monotonically increasing.

@examples[
    #:eval eval-for-docs
    (< 1 2 3)
    (< 2 1)
    (< "apple" "banana" "cherry")
  ]
}

@deftogether[(@defproc[(<= [v comparable?] ...)
              boolean?]
			  @defproc[(≤ [v comparable?] ...)
              boolean?])]{

 True if the v's are monotonically nondecreasing.

@examples[
    #:eval eval-for-docs
    (≤ 1 1 3)
    (≤ 2 1)
    (≤ "apple" "apple" "cherry")
  ]
}

@defproc[(= [#:key key (-> comparable? comparable?) #f] [v comparable?] ...)
              boolean?]{

 True if the v's are equal. This uses the most appropriate equality check for the type. For instance, it uses the built-in @racket[=] operator for numeric data, and @racket[equal?] for some other types such as @tech/reference{structures}. If a transformation is provided via the @racket[#:key] argument, then this transformation is applied to the input values first, prior to performing the equality check.

@examples[
    #:eval eval-for-docs
    (= 1 1 1)
    (= 1 2)
    (= "apple" "apple" "apple")
    (= 3/2 1.5)
    (= #:key identity 1 1 1)
    (= #:key string-upcase "apple" "Apple" "APPLE")
    (= #:key ->number "42.0" "42/1" "42")
    (= #:key ->number "42" "42.1")
    (= #:key even? 12 20)
    (= #:key odd? 12 20)
    (= #:key (.. even? ->number) "12" "20")
  ]
}

@deftogether[(@defproc[(/= [v comparable?] ...)
              boolean?]
              @defproc[(≠ [v comparable?] ...)
              boolean?])]{

 True if the v's are not equal. This is simply a negation of the generic @racket[=].

@examples[
    #:eval eval-for-docs
    (/= 1 1 2)
    (/= 1 1)
    (/= "apple" "Apple")
    (/= 3/2 1.5)
  ]
}

@deftogether[(@defproc[(>= [v comparable?] ...)
              boolean?]
			  @defproc[(≥ [v comparable?] ...)
              boolean?])]{

 True if the v's are monotonically nonincreasing.

@examples[
    #:eval eval-for-docs
    (≥ 3 1 1)
    (≥ 1 2)
    (≥ "banana" "apple" "apple")
  ]
}

@defproc[(> [v comparable?] ...)
         boolean?]{

 True if the v's are monotonically decreasing.

@examples[
    #:eval eval-for-docs
    (> 3 2 1)
    (> 1 1)
    (> "cherry" "banana" "apple")
  ]
}

@defproc[(comparable? [v any/c])
         boolean?]{

 Predicate to check if a value is comparable via the generic comparison operators @racket[<], @racket[<=], @racket[=], @racket[/=], @racket[>=] and @racket[>].

@examples[
    #:eval eval-for-docs
    (comparable? 3)
    (comparable? #\a)
    (comparable? "cherry")
    (comparable? (set))
    (comparable? (hash))
  ]
}