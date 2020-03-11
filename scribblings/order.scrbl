#lang scribble/doc
@require[scribble/manual
         scribble-abbrevs/manual
         scribble/example
		 racket/sandbox
         @for-label[relation/equivalence
                    relation/order
		            racket/generic
                    (except-in racket < <= = >= > min max)]]

@title{Order Relations}

@defmodule[relation/order]

A generic interface and utilities for orderable data. By default, the built-in comparison operators @racket[<], @racket[<=], @racket[=], @racket[>=] and @racket[>] operate on @tech/reference{numbers} specifically, while other comparable types like characters and strings have their own type-specific comparison operators, for instance @racket[char<?] and @racket[string<?]. This module provides a generic interface that overrides these standard operators to allow their use for any orderable type and not only numbers, and also provides additional utilities to support working with orderable data in a type-agnostic way. You can also provide an implementation for the interface in custom types so that they can be compared and reasoned about by using the same standard operators as well as the generic utilities provided here.

@(define eval-for-docs
  (parameterize ([sandbox-output 'string]
                 [sandbox-error-output 'string]
                 [sandbox-memory-limit #f])
                 (make-evaluator 'racket/base
				                 '(require relation)
				                 '(require racket/function)
								 '(require racket/set))))

@section[#:tag "order:interface"]{Interface}

@defthing[gen:orderable any/c]{

 A @tech/reference{generic interface} that represents any object that can be compared with other objects of the same type in terms of order, that is, in cases where we seek to know, "is this value less than or greater than that value?" Any type implementing this interface must also implement @racket[gen:comparable] unless the latter's default fallback of @racket[equal?] is adequate. The following built-in types have implementations for the order relations @racket[<], @racket[<=], @racket[>=] and @racket[>]:

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
    (< #:key string-upcase "apple" "APPLE")
    (< #:key ->number "42.0" "53/1")
  ]

 To implement this interface for custom types, the following methods need to be implemented:

 @defproc[(less-than? [v orderable?] ...)
                      boolean?]{

 A function taking an arbitrary number of arguments (i.e. a "variadic" function) that tests whether the arguments are each less than the next, i.e. whether they are monotically increasing. All arguments must be instances of the structure type to which the generic interface is associated (or a subtype of the structure type). The function must return true if the arguments form a monotonically increasing sequence, and false if not.
 }

 @defproc[(greater-than? [v orderable?] ...)
                      boolean?]{

 Similar to @racket[less-than?], but tests whether the arguments are each greater than the next, i.e. whether they are monotically decreasing.
 }

 @defproc[(less-than-or-equal? [v orderable?] ...)
                      boolean?]{

 Similar to @racket[less-than?], but tests whether the arguments are each either less than or equal to the next, i.e. whether they are monotically non-increasing.
 }

 @defproc[(greater-than-or-equal? [v orderable?] ...)
                      boolean?]{

 Similar to @racket[less-than?], but tests whether the arguments are each either greater than or equal to the next, i.e. whether they are monotically non-decreasing.
 }

}

@section[#:tag "order:utilities"]{Utilities}

 The following utilities are provided which work with any type that implements the @racket[gen:orderable] interface.

@defproc[(< [#:key key (-> orderable? orderable?) #f] [v orderable?] ...)
              boolean?]{

 True if the v's are monotonically increasing. If a transformation is provided via the @racket[#:key] argument, then it is applied to the arguments prior to comparing them.

@examples[
    #:eval eval-for-docs
    (< 1 2 3)
    (< 2 1)
    (< "apple" "banana" "cherry")
    (< #:key string-length "cherry" "blueberry" "abyssinian gooseberry")
  ]
}

@deftogether[(@defproc[(<= [#:key key (-> orderable? orderable?) #f] [v orderable?] ...)
              boolean?]
              @defproc[(≤ [#:key key (-> orderable? orderable?) #f] [v orderable?] ...)
              boolean?])]{

 True if the v's are monotonically nondecreasing. If a transformation is provided via the @racket[#:key] argument, then it is applied to the arguments prior to comparing them.

@examples[
    #:eval eval-for-docs
    (≤ 1 1 3)
    (≤ 2 1)
    (≤ "apple" "apple" "cherry")
    (≤ #:key string-length "cherry" "banana" "avocado")
  ]
}

@deftogether[(@defproc[(>= [#:key key (-> orderable? orderable?) #f] [v orderable?] ...)
              boolean?]
              @defproc[(≥ [#:key key (-> orderable? orderable?) #f] [v orderable?] ...)
              boolean?])]{

 True if the v's are monotonically nonincreasing. If a transformation is provided via the @racket[#:key] argument, then it is applied to the arguments prior to comparing them.

@examples[
    #:eval eval-for-docs
    (≥ 3 1 1)
    (≥ 1 2)
    (≥ "banana" "apple" "apple")
    (≥ #:key string-length "banana" "cherry" "apple")
  ]
}

@defproc[(> [#:key key (-> orderable? orderable?) #f] [v orderable?] ...)
              boolean?]{

 True if the v's are monotonically decreasing. If a transformation is provided via the @racket[#:key] argument, then it is applied to the arguments prior to comparing them.

@examples[
    #:eval eval-for-docs
    (> 3 2 1)
    (> 1 1)
    (> "cherry" "banana" "apple")
    (> #:key string-length "abyssinian gooseberry" "blueberry" "apple")
  ]
}

@defproc[(min [#:key key (-> orderable? orderable?) #f] [v orderable?] ...)
               orderable?]{

 Returns the minimum value. If @racket[key] is provided it is applied to the arguments prior to the comparison (this pattern is often referred to as "argmin" in math and programming literature). The values are compared using the canonical comparison for their type.

@margin-note{In the case of a nonlinear order (i.e. where there is no greatest or least element), @racket[min] would return an arbitrary local minimum. You should typically only use this function when you know that a global minimum exists.}

@examples[
    #:eval eval-for-docs
    (min 3 2 1)
    (min "cherry" "banana" "apple")
    (min (set 1 2) (set 1) (set 1 2 3))
    (min #:key string-length "apple" "banana" "cherry")
  ]
}

@defproc[(max [#:key key (-> orderable? orderable?) #f] [v orderable?] ...)
               orderable?]{

 Returns the maximum value. If @racket[key] is provided it is applied to the arguments prior to the comparison (this pattern is often referred to as "argmax" in math and programming literature). The values are compared using the canonical comparison for their type.

@margin-note{In the case of a nonlinear order (i.e. where there is no greatest or least element), @racket[max] would return an arbitrary local maximum. You should typically only use this function when you know that a global maximum exists.}

@examples[
    #:eval eval-for-docs
    (max 3 2 1)
    (max "cherry" "banana" "apple")
    (max (set 1 2) (set 1) (set 1 2 3))
    (max #:key string-length "apple" "banana" "cherry")
  ]
}

@defproc[(orderable? [v any/c])
         boolean?]{

 Predicate to check if a value is comparable via the generic order operators @racket[<], @racket[<=], @racket[>=] and @racket[>] (and consequently also @racket[min] and @racket[max]).

@examples[
    #:eval eval-for-docs
    (orderable? 3)
    (orderable? #\a)
    (orderable? "cherry")
    (orderable? (set))
    (orderable? (hash))
  ]
}