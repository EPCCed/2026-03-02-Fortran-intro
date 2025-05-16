---
title: "Functions and subroutines"
teaching: 10
exercises: 10
questions:
- "How can I factor code out into different program procedures?"
- "How do I control the flow of information into and out of procedures?"
objectives:
- "See how to create and call both functions and subroutines."
- "Use the `intent` attribute with dummy arguments to change their read and write permissions within the procedure."
- "Understand the meanings of `pure` and `recursive` procedures."
keypoints:
- "Functions and subroutines are referred to collectively as `_procedures_`."
- "Using `intent` for dummy variables allows control over whether updates to their values are permitted."
- "Procedures can be modified with prefixes such as `pure` and `recursive` which ensure respectively that the procedure has no side-effects and that it is able to directly or indirectly call itself."
- "Procedures may be defined as module sub-programs for which the compiler will automatically generate the contract block as part of the module file."
---

## What's the difference?

The difference between functions and subroutines is to a degree one of
context. A function returns a result and is generally used where it
is best invoked as part of an expression or assignment, schematically:
```
  value = my_function(arg1, arg2, ...)
```
Unlike C, it is not possible simply to discard a function result.
A subroutine, by contrast, does not return a result (it may be thought of as a
`void` function in C terms), but it is also invoked differently:
```
  call my_subroutine(arg1, arg2, ...)
```
Subroutines are generally used to express more lengthy algorithms.

Note that in the calling context, the arguments `arg1`, `arg2`, etc
are referred to as the _actual arguments_.


## Dummy arguments and `intent` attribute

Procedures may have zero or more arguments (referred to as the _dummy
arguments_ at the point at which the procedure is defined). Three
different cases can be identified:

1. read-only arguments whose values are not updated by the procedure;
2. read-write arguments whose values are expected to be defined on
   entry, and may also be updated by the procedure;
3. write-only arguments whose values are only defined on exit.

These three cases may be encoded in the declarations of the dummy
arguments of a procedure via the `intent` attribute . For example:
```
  subroutine print_x(x)

    real, intent(in) :: x

    print *, "The value of x is: ", x

  end subroutine print_x
```
Here, dummy argument `x` has `intent(in)` which tells the compiler that
any attempt to modify the value is erroneous (a compiler error will result).
This is different from C, where a change to an argument passed by value is
merely not reflected in the caller.

> ## Passing by reference
>
> If you are used to C/C++, you should remain aware here that the Fortran
> standard requires actual arguments to be passed to functions and subroutines
> in such a way that they 'appear' to have been passed by reference. How to do
> so is left to the compiler (which may use copies or actually pass by
> reference) but any changes made to a dummy argument inside a procedure _will_
> be reflected in the actual arguments passed to it, unless prevented by having
> `intent(in)`.
{: .callout}

If one wants to alter the existing value of the argument, `intent(inout)`
is appropriate:
```
  subroutine increment_x(x)

    real, intent(inout) :: x

    x = x + 1.0

  end subroutine increment_x
```
If the dummy argument is undefined on entry, or has a value which is
simply to be overwritten, use `intent(out)`, e.g.:
```
  subroutine assign_x(x)

    real, intent(out) :: x

    x = 1.0

  end subroutine assign_x
```
The `intent` attribute, as well as allowing the compiler to detect
inadvertent errors, provides some useful documentation for the
reader.

Local variables do not have intent and are declared as
usual.


### Exercise (2 minutes)

Attempt to compile the accompanying
[module1.f90](../exercises/09-functions-subroutines/module1.f90) and associated
main program [program1.f90](../exercises/09-functions-subroutines/program1.f90).
Check the error message emitted, and sort out the intent of the dummy arguments
in [module1.f90](../exercises/09-functions-subroutines/module1.f90).


## Functions
A function may be defined as:
```
function my_mapping(value) result(a)

  real, intent(in) :: value
  real             :: a

  a = ...

end function my_mapping
```

Formally,
```
[prefix] function function-name (dummy-arg-list) [suffix]
  [ specification-part ]
  [ executable-part ]
end [ function [function-name] ]
```
As ever, there is some elasticity in the exact form of the declarations
you may see. In particular, older versions did not have the `result()`
suffix, and the _function-name_ was used as the variable to which the
return value was assigned. E.g.,
```
real function length(area)
  real area
  length = sqrt(area)
end function length
```
The modern form should be preferred; the `result()` part allows the two
names to be decoupled.

### `pure` procedures

Procedures which have no side effects may be declared with the
`pure` prefix; this may provide useful information to the compiler
in some circumstances. E.g.,
```
pure function special_function(x) result(y)
  real, intent(in) :: x
  ! ...
end function special_function
```
There are a number of conditions which must be met to qualify for
`pure` status:
1. For a function, any dummy arguments must be intent(in);
2. No variables accessed by host association can be updated (and no variables with `save` attribute);
3. there must be no operations on external files;
4. there must be no `stop` statement.


### `recursive` procedures

If recursion is required, a procedure must be declared with the
`recursive` prefix. E.g.,
```
recursive function fibonacci(n) result(nf)
  ! ... implementation...
  nf = fibonacci(n-1) + fibonacci(n-2)
end function fibonacci
```
Such a declaration must be included for both types of recursion: direct (a
procedure calling itself) and indirect (a procedure calling another which in
turn calls the first).

## Subroutines

Subroutines follow the same rules as functions, except that there is no
`result()` suffix specification:

```
[prefix] subroutine subroutine-name (dummy-arg-list)
  [ specification-part ]
  [ executable-part ]
end [ subroutine [subroutine-name] ]
```

### `return` statement

One may have a `return` statement to indicate that control should
be returned to the caller, but it is not necessary (the `end`
statement does the same job). We will use `return` when we consider
error handling later.

## Placing procedures in modules

It is very often a good idea to include your procedures within modules beneath
the `contains` statement. Aside from leading to good organisation of code, this
has an extra advantage in that the compiler will then automatically generate the
contract block (forward declaration or prototype) for the procedure as part of
the module. This can make it easier when using certain types of procedures (such
as those with `allocatable` dummy arguments) or in certain contexts (such as
passing the procedure as an argument).

## Exercise (5 minutes)

1. Can your function for the evaluation of pi from the previous episodes safely
   be declared `pure`? You can also use the accompanying template
   [exercise_module1.f90](../exercises/09-functions-subroutines/exercise_module1.f90)
   and
   [exercise_program1.f90](../exercises/09-functions-subroutines/exercise_program1.f90)
   to check.
2. Add a new version of this calculation: a subroutine which takes the number of
   terms as an argument, and also returns the computed value in the argument
   list.
3. Add to the module a recursive function to compute the nth Fibonacci number,
   and test it in the main code. See, for example the page at
   [Wikipedia](https://en.wikipedia.org/wiki/Fibonacci_number).

Solutions are available in same directory.


{% include links.md %}
