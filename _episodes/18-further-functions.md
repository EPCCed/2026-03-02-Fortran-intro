---
title: "Procedures again: interfaces"
teaching: 10
exercises: 30
questions:
- "What is an interface and why might I need to write one?"
- "Can I use a function or a subroutine as an argument to another procedure?"
- "How can I write a procedure that will accept arguments of different types?"
- "Can I overload arithmetic and relational operators to work with my derived types?"
- "Can I write a function that will accept both scalar and array arguments?"
objectives:
- "Understand the need for interfaces and recognise when they are necessary."
- "Be able to write an interface to allow the passing of a procedure as an actual argument."
- "Understand and be able to implement overloading and polymorphism."
- "Understand what an `elemental` function is and be able to write one."
keypoints:
- "An interface provides important information about a procedure to the compiler. Without this information, the compiler may not be able to use it."
- "When using modules, interfaces are generated automatically and provided to the compiler."
- "If not in a module, a function can be made visible to the compiler by declaring it with the `external` attribute, but the compiler can go further by checking the argument types if you write a full, explicit `interface` block."
- "Interfaces can also be used to implement limited polymorphism and operator overloading for derived types."
- "An elemental function is one which can be applied to a scalar actual argument or element-by-element to an array actual argument."
---

So far, we have demanded that all procedures be defined as part of a
module. This has the important advantage that it makes the
_interface_ to the function or subroutine _explicit_ to the compiler,
and to other program units via the `use` statement. The compiler can
then check the order and type of the actual arguments.

Other situations arise where we may need to give the compiler additional
information about the interface.

## An external function

Consider a program unit (which may or may not be a separate file) which
contains a function declaration outside a module scope. E.g.,
```
  function my_mapping(i) result(imap)
    integer, intent(in) :: i
    integer             :: imap
    ...
  end function my_mapping
```
If we compile a program which includes a reference to this function,
an error may result. We have not given the compiler any information
about how the function is meant to be called.

It is possible to provide the compiler with some limited information
about the return value of the function with the `external` attribute
(also available as a statement). E.g.,
```
  program example

    implicit none
    integer, external :: my_mapping
    ...
```

However, we have still not given the compiler full information about
the interface. The interface is said to remain _implicit_. To make
it explicit, the `interface` construct is available:
```
  program example

    implicit none
    interface
      function my_mapping(i) result(imap)
        integer, intent(in) :: i
	      integer             :: imap
      end function my_mapping
    end interface

    ...
```
This has provided a full, explicit, statement about the interface of the
function `my_mappping()`. (Note that the dummy argument names are not
significant, but the function name and the argument types and intents are.)

The compiler should now be able to check the arguments are used correctly
in the calling program (as if we had declared the function in a module).

Interface blocks are necessary in other contexts.

### Exercise (5 minutes)

> ## Externals and interfaces
>
> To illustrate the points made above, a very simple external function is defined
> in the file [external.f90](../exercises/18-further-functions/external.f90), and
> an accompanying program
> [example1.f90](../exercises/18-further-functions/example1.f90) calls the
> function therein.
>
> Try to compile the two files, e.g.:
> ```
> $ ftn external.f90 example1.f90
> ```
> What happens?
> 
> Try adding the appropriate `external` declaration
> ```
>   integer, external :: array_size
> ```
> What happens if you try to compile the program now? (Note at this point that
> there are no modules involved, so no `.mod` files will appear).
>
> Then try running the program. Is the output what you expect?
>
> Finally, remove the `external` declaration and try to introduce the
> correct `interface` block. What happens now?
> 
> > ## Solution
> > 
> > Without either the `external` declaration of the function or an interface,
> > the compilation will simply fail. `gfortran` produces the following:
> > ```
> > example1.f90:24:33:
> > 
> >    24 |   print *, "The array size is: ", array_size(a), size(a)
> >       |                                 1
> > Error: Function 'array_size' at (1) has no IMPLICIT type
> > ```
> > {: .output}
> > 
> > Adding the `external` declaration allows compilation to succeed, but the
> > following output is produced on running the program:
> > ```
> >  The array size is:            0           6
> > ```
> > {: .output}
> > The function call returns an incorrect value of 0 where the
> > (3,2) array has an actual size of 6.
> >
> > Removing the external declaration and adding an interface matching the function
> > in `external.f90` as follows will help (and you may have already spotted the issue):
> > ```
> >   interface
> >     function array_size(a) result(isize)
> >       real, dimension(:), intent(in) :: a
> >       integer                          :: isize
> >     end function array_size
> >   end interface
> > ```
> > {: .source}
> >
> > Compiling now produces an error again, as reported here by `gfortran`:
> > ```
> > example1.f90:23:45:
> > 
> >    23 |   print *, "The array size is: ", array_size(a), size(a)
> >       |                                             1
> > Error: Rank mismatch in argument 'a' at (1) (rank-1 and rank-2)
> > ```
> > {: .output}
> > In the main program we were attempting call `array_size()` on a rank two array,
> > while in `external.f90` we implemented it for rank one arrays. Now that we have
> > an interface, the compiler can see that the way we're calling the function is
> > incorrect, so it produces the error and fails compilation.
> >
> > This is preferable to the `external` declaration by which we essentially asked
> > the compiler to trust that it can call `array_size()` however we tell it to do so,
> > even though it was in this case incorrect.
> > 
> {: .solution}
{: .challenge}


## Passing functions or subroutines as arguments

Sometimes it is convenient to provide a procedure as an argument to
another function or subroutine. Good examples of this are for
numerical optimisation or numerical integration methods where
a user-defined function needs to be evaluated for a series of
different arguments which cannot be prescribed in advance.

This can be done if an interface block is provided which describes to the
calling procedure the function that is the dummy argument. E.g.,
```
  subroutine my_integral(a, b, afunc, result)
    real, intent(in) :: a
    real, intent(in) :: b
    interface
      function afunc(x) result(y)
        real, intent(in) :: x
	      real                y
      end function afunc
    end interface
    ...
```
The function dummy argument has no intent. One cannot in general
use intrinsic procedures as actual arguments.


## Limited polymorphism

We have seen a number of intrinsic functions which take arguments of
different types, such as `mod()`. Such a situation where the arguments
can take a different form is sometimes referred to as limited polymorphism
(or overloading).

However, it is not possible in Fortran to define two procedures of the same
name, but different arguments (at least in the same scope). We need different
names; suppose we have two module sub-programs, schematically:

```
   subroutine my_specific_int(ia)
     integer, intent(inout) :: ia
     ... integer implementation ...
   end subroutine my_specific_int

   subroutine my_specfic_real(ra)
     real, intent(inout) :: ra
     ... real implementation ...
   end subroutine my_specific_real
```
A mechanism exists to allow the compiler to identify the correct routine
based on the actual argument when used with a _generic name_. This is:
```
  interface my_generic_name
    module procedure my_specific_int
    module procedure my_specific_real
    ...
  end interface my_generic_name
```
This should appear in the specification (upper) part of the relevant module.
The two specific implementations must be distinguishable by the compiler,
that is, at least one non-optional dummy argument must be different.

### Exercise

> ## An interface for polymorphic PBMs
>
> In the earlier [episode on I/O]({{ page.root }}{% link _episodes/13-IO.md %}),
> we wrote a module to produce a `.pbm` image file. The accompanying module
> [pbm_image.f90](../exercises/18-further-functions/pbm_image.f90) provides two
> implementations of such a routine: one for a logical array, and another for an
> integer array.
>
> Check you can add the appropriate `interface` block with the generic name
> `write_pbm` to allow the program
> [example3.f90](../exercises/18-further-functions/example3.f90) to be compiled
> correctly.
> 
> > ## Solution
> > 
> > We need to add an interface to the module specification for `write_pbm`
> > which allows use of both the `write_logical_pbm` and `write_integer_pbm`
> > subroutines. You should be able to follow the description above to do so.
> > The only minor complication is that the module uses `private` by default;
> > unless we specify `public` for the new generic interface, it will remain
> > hidden from the main program.
> >
> > Putting this together, the following should allow you to compile and run
> > the program with no errors:
> > ```
> >   public :: write_pbm
> >   interface write_pbm
> >     module procedure write_logical_pbm
> >     module procedure write_integer_pbm
> >   end interface
> > ```
> > {: .source}
> > With this, the internal workings of the module are hidden away and its
> > use is entirely via `write_pbm`.
> > 
> {: .solution}
{: .challenge}


## Operator overloading

For simple derived types it may be meaningful to define relational
and arithmetic operators. For example, if we had a date type such as
```
  type :: my_date
    integer :: day
    integer :: month
    integer :: year
  end type my_date
```
it may be meaningful to ask whether two dates are equal and so on (it would
not really be meaningful to add one date to another).

One can write a function to do this:
```
  function my_dates_equal(date1, date2) result(equal)
    type (my_date), intent(in) :: date1
    type (my_date), intent(in) :: date2
    logical                       equal
    ! ...
  end function my_dates_equal
```
As a syntactic convenience, it might be useful to use `==` in a logical
expression using dates. This can be arranged via
```
  interface operator(==)
    module procedure my_dates_equal
  end interface
```
Again this should appear in the relevant specification part of the
relevant module. Such overloading is possible for relational operators
`==`, `/=`, `>=`, `<=`, `>` and `<`. If appropriate, overloading is also
available for arithmetic operators `+`, `-`, `*`, and `/`.

It is also possible to overload assignment `=`.


## Elemental functions

Again, we have seen that some intrinsic functions allow either scalar
or array actual arguments. The same effect can be achieved for a
user-defined function by declaring it to be _elemental_. The procedure
is declared in terms of a scalar dummy argument, but then may be
applied to an array actual argument element by element.

Such a procedure should be declared:
```
  elemental function my_function(a) result(b)
    integer, intent(in) :: a
    integer             :: b
    ! ...
  end function my_function
```
An invocation should be, e.g.:
```
   iresult(1:4) = my_function(ival(1:4))
```

All arguments (and function results) must conform. An elemental routine
usually must also be `pure`.


### Exercise (5 minutes)

> ## Elemental conversion from logical to PBM
>
> In the [pbm_image.f90](../exercises/18-further-functions/pbm_image.f90) module
there is a utility function `logical_to_pbm()` which is used in
`write_logical_pbm()` to translate the logical array to an integer array.
Refactor this part of the code to use an elemental function.
> 
> > ## Solution
> > 
> > The function `logical_to_pbm()` is currently `pure` and takes in
> > a scalar logical `lvar` to return the scalar integer `ivar`. The function
> > is currently `pure`. Everything is already in place to convert the function to
> > `elemental`:
> > ```
> >   elemental function logical_to_pbm(lvar) result (ivar)
> > 
> >     ! Utility to return 0 or 1 for .false. and .true.
> > 
> >     logical, intent(in) :: lvar
> >     integer             :: ivar
> > 
> >     ivar = 0
> >     if (lvar) ivar = 1
> > 
> >   end function logical_to_pb
> > ```
> > {: .source}
> >
> > All that remains is to have `write_logical_pbm()` call this new `elemental`
> > version. Further down in that function you will see the old nested loop to
> > move through the `map` array and from it use `logical_to_pbm()` to fill the
> > `imap` array:
> > ```
> >     do j = 1, size(map, dim = 2)
> >        do i = 1, size(map, dim = 1)
> >           imap(i,j) = logical_to_pbm(map(i,j))
> >        end do
> >     end do
> > ```
> > {: .source}
> > With the new `elemental` version of `logical_to_pbm()`, we can replace this
> > entire structure with the single line:
> > ```
> > imap(:,:) = logical_to_pbm(map(:,:))
> > ```
> > {: .source}
> > 
> {: .solution}
{: .challenge}


## Exercise (20 minutes)

> ## Exercise name
>
> Write a module/program to perform a very simple numerical integration
> of a simple one-dimensional function _f(x)_. We can use a
> trapezoidal rule: for lower and upper limits _a_ and _b_, the
> integral can be approximated by
> ```
>   (b - a)*(f(a) + f(b))/2.0
> ```
> We can go further and split the interval between `a` and `b` into small sections
> of size `h = (b - a)/n`. In a similar manner, approximating the integral of each
> small section with a trapezium allows us to estimate the total integral to be
> ```
>   h*(f(a) + sum + f(b))/2.0
> ```
> with the sum
> ```
>   sum = 0.0
>   do k = 1, n-1
>     sum = sum + 2.0*f(a+k*h)
>   end do
> ```
> Write a procedure that will take the limits `a` and `b`, the integer number
> of steps `n`, and the function, and returns a result.
> 
> To check, you can evaluate the function `cos(x) sin(x)` between `a = 0`
> and `b = pi/2` (the answer should be 1/2). Check your answer gets better
> for value of `n = 10, 100, 1000`.
> 
> > ## Solution
> > 
> > A sample solution is provided in [integral_program.f90](../exercises/18-further-functions/solutions/integral_program.f90) and
> > [integral_module.f90](../exercises/18-further-functions/solutions/integral_module.f90).
> > 
> {: .solution}
{: .challenge}

{% include links.md %}
