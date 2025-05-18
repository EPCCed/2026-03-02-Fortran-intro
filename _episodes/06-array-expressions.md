---
title: "Array expressions and assignments"
teaching: 10
exercises: 20
questions:
- "How do I assign values to Fortran arrays?"
- "Can I work at once with subsets of an array?"
- "How can I reduce or extract information from an array?"
objectives:
- "Learn the syntax used to work with array sections."
- "Learn about array reductions."
- "Understand how to use arrays in logical expressions."
keypoints:
- "Fortran allows flexible operations on arrays or subsets of array elements and provides numerous intrinsic functions for such operations."
- "Some of these, such as `all()` and `any()` can be useful in directing the logical flow of a program."
---

## Array sections

A general subset of array elements, an _array section_,  may be constructed
from a triplet with a start and end subscript and a stride:
```
  [subscript] : [subscript] [: stride]
```
Given a rank 1 array `a(:)`, some valid array sub-objects are:
```
  a         ! the whole array
  a(:)      ! the whole array again
  a(1:4)    ! array section [ a(1), a(2), a(3), a(4) ]
  a(:4)     ! all elements up to and including a(4)
  a(2::2)   ! elements a(2), a(4), a(6), ...
```
If an array subscript is present, it must be valid; if the stride is present
it may not be zero.


## Array expressions and assignments

Intrinsic operations can be used to construct expressions which are
arrays. For example:
```
  integer, dimension(4, 8) :: a1, a2
  integer, dimension(4)    :: b1

  a1 = 0                      ! initialise all elements to zero
  a2 = a1 + 1                 ! all elements of a2(:,:)
  a1 = 2*a1                   ! multiplied element-wise

  b1 = a1(:, 1)               ! b1 set to first column of a1
```
Such expressions and assignments must take place between entities with
the same shape (they are said to _conform_). A scalar conforms
with an array of any shape.

Given the above declarations, the following would not make sense:
```
  b1 = a1
```

### Exercise (2 minutes)

> ## Array appearance
>
> A caution. How should we interpret the following assignments?
> ```
>   d = 1.0
>   e(:) = 1.0
> ```
> Compile the accompanying program
> [example1.f90](../exercises/06-array-expressions/example1.f90), check the
> compilation errors and improve the program.
> 
> > ## Solution
> >
> > The first assignment given above is ambiguous. Is `d` a scalar variable, or
> > an entire array? The second assignment is clearly on every element of the
> > rank-1 array `e`.
> > 
> > The compiler errors you get when compiling
> > [example1.f90](../exercises/06-array-expressions/example1.f90) may spell out
> > exactly what is going wrong. At line 13,
> > ```
> > b1 = a1
> > ```
> > {: .source}
> > `b1` is a rank-1 array; the rank-2 array `a1` cannot be used to assign values to it. Change it to
> > ```
> > b1(:) = a1(:,1)
> > ```
> > {: .source}
> >
> > Then, the second issue is the assignment
> > ```
> > b1(1:4) = a2(1, 4:4)
> > ```
> > {: .source}
> > as the section `a2(1, 4:4)` is an array of the incorrect size
> > (note that `a2(1, 4)` would work as it becomes a scalar, but wouldn't set
> > `b2` to the first half of the first row of `a2`). To correct the error, fix
> > the start index:
> > ```
> > b1(1:4) = a2(1, 1:4)
> > ```
> > {: .source}
> > 
> {: .solution}
{: .challenge}

> ## Array style
>
> Following this exercise, you hopefullly agree it may be a good idea to prefer
> use of `a(:)` over `a` when referencing the whole array. The former has the
> appearance of an array, while the latter may incorrectly appear to be a scalar
> to an unfamiliar reader of the code (or you yourself if it's been a while
> since you last read it).
{: .callout}

## Elemental intrinsic functions

Many intrinsic functions are _elemental_: that is, a call with a scalar
argument will return a scalar, while a call with an array argument will
return an array with the result of the function for each individual
element of the argument.
For example,
```
   real, dimension(4) :: a, b
   ...
   b(1:4) = cos(a(1:4))
```
will fill each element of `b` with the cosine of the corresponding element in
`a`.

## Reductions

Other intrinsic functions can be used to perform reduction operations
on arrays, and usually return a scalar. Common reductions are
```
   a = minval( [1.0, 2.0, 3.0] )  ! the minimum value from the array
   b = maxval( [1.0, 2.0, 3.0] )  ! the maximum value from the array
   c = sum(array(:))              ! the sum of all values in the array
```

## Logical expressions and masks

There is an array equivalent of the `if` construct called `where`, e.g.,:
```
  real, dimension(20) :: a
  ...
  where (a(:) >= 0.0)
    a(:) = sqrt(a(:))
  end where
```
which performs the appropriate operations element-wise. Formally,
```
  where (array-logical-expr)
    array-assignments
  end where
```
in which all the _array-logical-expr_ and _array-assignments_ must have the
same shape.

Logical functions `any()`, `all()`, and others may be used to reduce logical
arrays or array expressions. These return a `logical` value so can be used in an
`if` statement:
```
   if (any(a(:) < 0.0)) then
     ! do something if at least one element of a(:) is negative
   end if
   if (all(a(:) < 0.0)) then
     ! do something if every element of a(:) is negative
   end if
```
Some intrinsic functions have an optional mask argument which can be used to
restrict the operations to certain elements, e.g.,
```
  b = min(array(:), mask = (array(:) > 0.0))     ! minimum of positive value
  n = count(array(:), mask = (array(:) > 0.0))   ! count the number of positive values
```
These may be useful in certain situations.

### Another caution

There may be a temptation to start to construct array expressions of baroque
complexity, perhaps in the search for brevity. This temptation is probably
best avoided:

1. Such expressions can become very hard to read and interpret for correctness;
2. Performance: compilers may struggle to generate the best code if expressions are very complex. Array expressions and constructs may not work in parallel: explicit loops may provide better opportunities.

If array expressions are used, simple ones are best.

### Exercise (5 minutes)

> ## Quadratic equation
>
> The template [exercise1.f90](../exercises/06-array-expressions/exercise1.f90)
> re-visits the quadratic equation exercise. Check you can replace the scalars
> where appropriate. See the template for further instructions.
> 
{: .challenge}

> ## Sieve of Eratosthenes
>
> Here's an additional exercise: write a program to implement the [Sieve of
> Eratosthenes](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes) algorithm
> which performs a search for prime numbers. See
> [exercise2.f90](../exercises/06-array-expressions/exercise2.f90) for a template
> with some further instructions. How much array syntax can you reasonably
> introduce?
> 
> > ## Solution
> > 
> > A sample solution is provided in [solution.f90](../exercises/06-array-expressions/solutions/solution.f90).
> > 
> {: .solution}
{: .challenge}


{% include links.md %}
