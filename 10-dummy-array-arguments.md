---
title: More on array dummy arguments
teaching: 10
exercises: 10
---

::::::::::::::::::::::::::::::::::::::: objectives

- Understand the meaning of an assumed shape array and where care needs to be taken with its bounds.
- Be able to use the intrinsic `lbound()` and `ubound()` functions.
- Understand the conditions around the usage of allocatable arrays as dummy arguments.
- Make some arguments optional and be able to provide them using keyword arguments.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- What do I need to take into consideration when passing an array as an argument?
- Can I pass arrays which haven't yet been allocated?
- How do I implement optional dummy arguments?

::::::::::::::::::::::::::::::::::::::::::::::::::

## Array dummy arguments

When a dummy argument is an array, we need to think about how we want the
procedure to know about its shape.

### Explicit shape

One is entitled to make explicit the shape of an array in a procedure
definition, e.g.,

```fortran
  subroutine array_action1(nmax, a)
    integer, intent(in)                    :: nmax
    real, dimension(1:nmax), intent(inout) :: a
    ...
  end subroutine array_action1
```

and similarly for arrays of higher rank. As before, if the lower bound
of the array is unspecified, it takes on the default value of `1`.

### Assumed shape

However, it may be more desirable to leave the exact shape
implicit in the array itself, e.g.,

```fortran
  subroutine array_action2(a, b)
    real, dimension(:,:), intent(in) :: a
    real, dimension(:,:), intent(inout) :: b
    ...
  end subroutine array_action2
```

Note that the rank is always explicit.

There are pros and cons to this: it is slightly more concise and general,
but some care may need to be exercised with the distinction between
*extents* and bounds. It is the *shape* that is passed along with the
actual arguments, and not the bounds.

:::::::::::::::::::::::::::::::::::::::::  callout

## Bounds, extents and shapes

Remember from the earlier lesson on arrays that the number of elements an array has in
a given dimension is that dimension's *extent*. The ordered set of extents is the array's *shape*.
The bounds are the minimum and maximum indices used in each dimension.


::::::::::::::::::::::::::::::::::::::::::::::::::

### `lbound()` and `ubound()` again

You will have seen the `lbound()` and `ubound()` functions being used during the
[example](files/exercises/05-arrays/example1.f90) in the earlier [episode on
arrays](05-arrays.md). These functions
return a rank one array which is the relevant bound in each dimension. The
optional argument `dim` can be used to obtain the bound in the corresponding
rank or dimension e.g.,

```fortran
  real, dimension(:,:), intent(in) :: a
  integer :: lb1, lb2

  lb1 = lbound(a, dim = 1)  ! lower bound in first dimension
  lb2 = ubound(a, dim = 2)  ! upper bound in second dimension
```

### Exercise (4 minutes)

:::::::::::::::::::::::::::::::::::::::  challenge

## Checking array bounds

Consider the accompanying example in
[program1.f90](files/exercises/10-dummy-array-arguments/program1.f90) and
[module1.f90](files/exercises/10-dummy-array-arguments/module1.f90). Is the code
correct? Add calls to `lbound()` and `ubound()` in the subroutine to check.

What do you think was the intention of the programmer? What remedies are
available?

::::::::::::::::::::::::::::::::::::::::::::::::::

### Automatic arrays

One is allowed to bring into existence 'automatic' arrays on the stack.
These are usually related to temporary workspace, e.g.,

```fortran
subroutine array_swap1(a, b)
  integer, dimension(:), intent(inout) :: a, b
  integer, dimension(size(a))          :: tmp

  tmp(:) = a(:)
  a(:)   = b(:)
  b(:)   = tmp(:)
end subroutine array_swap1
```

In this example, the same effect could have been achieved using a
loop and a temporary scalar.

### Allocatable dummy arguments

It may occasionally be appropriate to have a dummy
argument with both an intent and `allocatable` attribute.

```fortran
  subroutine my_storage(lb, ub, a)

    integer, intent(in) :: lb, ub
    integer, dimension(:), allocatable, intent(out) :: a

    allocate(a(lb:ub))

  end subroutine my_storage
```

There are a number of conditions to such usage.

1. The corresponding actual argument must also be allocatable (and have the same
  type and rank);
2. If the intent is `intent(in)` the allocation status cannot be changed;
3. If the intent is `intent(out)` and the array is allocated on entry, the array
  is automatically deallocated.

The intent applies to both the allocation status and to the array itself.
Some care may be required.

A `function` may have an allocatable result which is an array; this might
be thought of as returning a temporary array which is automatically
deallocated when the relevant calling expression has been evaluated.

## Optional arguments

We have encountered a number of intrinsic procedures with optional dummy
arguments. Such procedures may be constructed with the `optional`
attribute for a dummy argument, e.g.:

```fortran
  subroutine do_something(a, flag, ierr)
    integer, intent(in)            :: a
    logical, intent(in),  optional :: flag
    integer, intent(out), optional :: ierr

  end subroutine do_something
```

Any operations on such optional arguments should guard against the
possibility that the corresponding actual argument was not present
using the intrinsic function `present()`. E.g.,

```fortran
  local_flag = some_default_value
  if (present(flag)) local_flag = flag
```

Any attempt to reference a missing optional argument will generate an error.

The one exception is that an optional argument may be passed directly
as an actual argument to another procedure where the corresponding
dummy argument is also optional.

### Positional and keyword arguments

Procedures will often have a combination of a number of mandatory
(non-optional) dummy arguments, and optional arguments. These may be
mixed via the use of keywords, which are the dummy argument name. E.g.,
using the subroutine defined above:,

```fortran
  call do_something(a, ierr = my_error_var)
```

Here, `a` is appearing as a conventional positional argument, while
a keyword argument is used to select the appropriate optional
argument `ierr`. The rules are:

1. no further positional arguments can appear after the first keyword argument;
2. positional arguments must appear exactly once, keyword arguments at most once.

## Exercise (10 minutes)

:::::::::::::::::::::::::::::::::::::::  challenge

## Tri-diagonal modules

Consider again the problem of the tri-diagonal matrix.

Refactor your existing stand-alone program (or use the template
[exercise.f90](files/exercises/10-dummy-array-arguments/exercise.f90)) to provide a
module subroutine such as

```fortran
  subroutine tridiagonal_solve(b, a, c, rhs, x)
```

where `b`, `a`, and `c` are arrays of the relevant
extent to represent the diagonal elements, the lower diagonal elements
and the upper diagonal elements respectively. Use the `size()` intrinsic
to determine the current size of the matrix in the subroutine. The extent
of the off-diagonal arrays should be one less element. The `rhs` is the
vector of right-hand side elements, and `x` should hold the solution on
exit. Assume, in the first instance, that all the arrays are of the
correct extent on entry.

Check your result by calling the subroutine from a main program with some
test values. (You may wish to take two copies of the template `exercise.f90`
and use one as the basis of a module, and the other as the basis of the main
program.)

What do you need to do if the diagonal `b` and the right-hand side `d` arrays
should be declared `intent(in)`?

What checks would be required in a robust implementation of such a routine?

:::::::::::::::  solution

In the original implementation, the diagonal and right-hand side are destroyed during
the calculation. To use `intent(in)` with the dummy arguments, we have to leave them
untouched. That means making copies in local automatic arrays and using those instead.

A robust implementation would need to include checks on the bounds of the dummy arrays
to make sure that they correctly conform to one another.

Sample solutions are available in the later [episode on derived types](16-data-structures.md)
in [exercise\_program.f90](files/exercises/16-data-structures/exercise_program.f90)
and
[exercise\_module.f90](files/exercises/16-data-structures/exercise_module.f90).

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::



:::::::::::::::::::::::::::::::::::::::: keypoints

- There are some additional considerations to think about when dummy arguments are arrays.
- You may wish to pass the shape of the array explicitly, at the cost of providing more dummy arguments.
- Arrays may have an assumed shape, but remember that they only receive the shape and not the original bounds of its dimensions.
- Allocatable arrays can also be used as dummy arguments.
- Dummy arguments can have the `optional` attribute. The corresponding actual arguments can be positional or provided as a keyword argument.

::::::::::::::::::::::::::::::::::::::::::::::::::


