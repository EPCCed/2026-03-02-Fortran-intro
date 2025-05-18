---
title: "Array declarations"
teaching: 10
exercises: 10
questions:
- "How do I create arrays of different sizes and numbers of dimensions?"
- "Can I create the arrays at runtime if I don't yet know how big they need to be?"
objectives:
- "Understand how to create arrays of one, two and more dimensions."
- "Recognise and use array terminology."
- "Be able to create and use allocatable arrays."
- "Get help from the compiler if things go wrong."
keypoints:
- "Unlike C, which often uses pointers to handle array data, Fortran has arrays which are an intrinsic feature of the language."
- "The number of dimensions in an array is its _rank_."
- "The number of elements in one of an array's dimensions is its _extent_."
- "The ordered sequence of extents in an array is its _shape_."
- "The total number of elements in an array, equal to the product of its shape, is its _size_."
- "In Fortran array indices begin at 1 by default, but this can be changed if required."
- "New arrays can be created by using the intrinsic `reshape()` function with an existing one."
- "An array with an unknown size can be allocated at runtime."
- "Compilers are typically able to help you debug issues with arrays if you ask them to."
---

## A one-dimensional array

Arrays may be declared with addition of the `dimension` attribute, e.g.,
```
program example1

  implicit none

  real, dimension(3) :: a    ! declare a with elements a(1), a(2), a(3)

end program example1
```
The _size_ of the array is the total number of elements (here 3).
The default _lower bound_ is 1 and the _upper bound_ is 3.

In a slightly older style you may also see arrays declared by placing the size
of the array directly after the name, e.g. and equivalently,
```
  real :: a(3)               ! declare a with elements a(1), a(2), a(3)
```

> ## Fortran array indexing
>
> Very importantly, Fortran arrays by default begin their indexing at 1. This is
> in direct contrast to other languages such as C, C++ and Python which begin at 0.
> Both styles have advantages and disadvantages; the Fortran standard has
> simply settled on a style that more closely resembles the indexing of
> mathematical matrices, while starting from 0 makes the offset in the memory
> more visible.
{: .callout}


### Lower and upper bounds
If necessary or useful, you can however choose yourself the bounding indices of
your arrays:
```
  real, dimension(-2:1) :: b ! elements b(-2), b(-1), b(0), b(1)
```
Here we specify, explicitly, the lower and upper bounds. The
_size_ of this array is 4.


### Array constructor

One may specify array values as a constructor
```
  integer, dimension(3), parameter :: s = (/ -1, 0, +1 /)   ! F2003 or
  integer, dimension(3), parameter :: t = [  -1, 0, +1 ]    ! F2008
```

## A two-dimensional array
```
  real, dimension(2,3) :: a   ! elements a(1,1), a(1,2), a(1,3)
                              !          a(2,1), a(2,2), a(2,3)
```
This two-dimensional array (said to have _rank_ 2) has two elements
in the first dimension (or _extent_ 2), and 3 elements in the second
dimension (_extent_ 3). It is said to have _shape_ (2,3), which is
the sequence of extents in each dimension. Its size is 6 elements.

There is an array element order which in which we expect the implementation
to store contiguously in memory. In Fortran this has to be the left-most
dimension counting fastest. For array `a` we expect the order in
memory to be
```
a(1,1), a(2,1), a(1,2), a(2,2), a(1,3), a(2,3)
```
that is, the opposite the convention in C.

> ## Looping through multi-dimensional arrays
>
> In you write a loop which moves through an array, remember that you will
> typically move most quickly through the first index. That means that generally
> the innermost loop's control variable should be used for the first index, the
> next outer loop should use the second control variable, and so on, e.g.,
> ```
> do j = 1, 10
>   do i = 1, 20
>     a(i,j) = ...   ! Do work to calculate the (i,j)th element of a
>   end do
> end do
> ```
{: .callout}

The principles of rank-2 arrays can be extended to higher ranks. The standard
requires support for a minimum of rank-15 arrays, but individual compilers may
allow for even more. 

### `reshape`

A constructor for an array of rank 2 or above might be used, e.g.,
```
  integer, dimension(2,3) :: m = reshape([1,2,3,4,5,6], shape = [2,3])
```
where we have used the intrinsic function `reshape()`.

`reshape()` can be used wherever you might need to alter an array's shape.

### Exercise (2 minutes)

> ## Array sizes and shapes
>
> Check the accompanying [example1.f90](../exercises/05-arrays/example1.f90) to
> see examples of intrinsic functions available to interrogate array size and
> shape at run time.
> 
{: .challenge}


## Allocatable arrays

If we wish to establish storage with shape determined at run time, the
_allocatable_ attribute can be used. The rank must be specified but the value of
the extent in each dimension is deferred using the `:` symbol:
```
  real, dimension(:, :), allocatable :: a

  ! ... establish shape required, say (imax, jmax) ...

  allocate(a(imax, jmax))

  ! ... use and then release storage ...

  deallocate(a)
```
Again, this array will take on the default lower bound of 1 in each
dimension.

Formally,
```
  allocate(allocate-list [, source = array-expr] [ , stat = scalar-int-var])
```
The optional `source` argument may be used to provide a template for
the newly allocated object (values will be copied). We will return to
this in more detail in the context of dynamic type.

A successful allocation with the optional `stat` argument will assign a
value of zero to the argument.

### Allocation status

An array declared with the _allocatable_ attribute is initially in
an unallocated state. When allocated, this status will change; this
status can be interrogated via the intrinsic function `allocated()`.
```
  integer, dimension(:), allocatable :: m
  ...
  if (allocated(m)) then
    ! ... we can do something ...
  end if
```
An attempt to `deallocate` a variable which is not allocated is an error.


### Exercise (5 minutes)

> ## Computing pi with arrays
>
> Return again to the program to compute the approximation of pi via
> the Gauss-Legendre expansion (last seen in the [previous episode on do loops]({{ page.root }}{% link _episodes/04-do-statements.md %})).
> You may use
> your own version or the new template provided in this directory
> (see [exercise1.f90](../exercises/05-arrays/exercise1.f90)).
>
> Introduce array storage for the quantites `a`, `b` and `t`. Use a
> fixed number of terms. Assign appropriate values in a first loop.
> In a second loop, compute the approximation of pi at each iteration.
>
> What might you do if you wanted to store only the number of terms
> taken to reach a converged answer?
> 
{: .challenge}


#### Help is available!

As arrays are self-describing in Fortran, it is relatively easy for the
compiler to analyse whether array accesses are valid, or within bounds.
This can help debugging. Most compilers will have an option that instructs
the compiler to inject additional code which checks bounds at run time.
For the Cray Fortran compiler, this is `-hbounds`; for the GNU compiler,
this is `-fcheck=bounds`.

E.g.,
```
$ ftn -hbounds exercise1.f90
```
Some compilers may also be able to check certain bounds at compile
time, and issue a compile-time message. However, in general, errors
may not appear until run time. If your program crashes, or produces
unexpected results, this compiler option can help to track down
problems with invalid array accesses.

{% include links.md %}
