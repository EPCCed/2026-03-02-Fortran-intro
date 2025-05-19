---
title: "Modules and compilation of modules"
teaching: 10
exercises: 10
start: True
questions:
- "How can I collect parameters and sub-programs of my own in a module?"
- "Can I keep some parts of the module internal to it and hidden?"
- "Am I able to use scoping to introduce temporary variables in a larger program unit?"
objectives:
- "Learn how to write a non-intrinsic module of your own, and understand what is and isn't appropriate to place within them.."
- "Understand how to use `public` and `private` within a module to control what components are visible externally."
- "Use the `block` construct to control the scope of names within larger program structures."
keypoints:
- "Modules in Fortran provide _the_ way to structure collections of related definitions and operations, and make them available elsewhere."
---

## Module structure

We have already used one _intrinsic module_ (`iso_fortran_env`); we
can also write our own, e.g.,
```
module module1

  implicit none
  integer, parameter :: mykind = kind(1.d0)

contains

  function pi_mykind() result(pi)   ! Return the value of a well-known constant

    real (kind = mykind) :: pi
    pi = 4.0*atan(1.0_mykind)

  end function pi_mykind

end module module1
```
We may now `use` the new module in other _program units_ (main program or
other modules). For example:
```
program example1

  use module1
  implicit none

  real (kind = mykind) :: value
  value = pi_mykind()

end program example1
```
Here both the parameter `mykind` and the function `pi_mykind()` are said
to be available by _use association_. Note that any `use` statements
must come before the `implicit` statement.

Formally, the structure of a module is:
```
  module module-name
    [specification-statements]
  [ contains
    module-subprograms ]
  end [ module [ module-name ]]
```
The `contains` statement separates the specification statements from module
sub-programs. Sub-programs, or _procedures_,  consist of functions and/or
subroutines which will cover in the [next episode]({{ page.root }}{% link
_episodes/09-functions-subroutines.md %}).

### Digression: compilation of modules, and programs

One would typically expect modules and a main program to be in
separate files, e.g.,:
```
$ ls
module1.f90     program1.f90
```
It is often convenient to use the same name for the both module and
the corresponding file (with extension `.f90`). You can do
differently, but it can become confusing. Likewise for the main program.

We can compile the module, e.g.,
```
$ ftn -c module1.f90
```
where the `-c` option to the Fortran compiler `ftn` requests compilation
only (no link). This should give us two new files:
```
$ ls
module1.f90     module1.mod     module1.o       program1.f90
```
The first is a compiler-specific _module file_ (usually with a `.mod`
extension). This plays the role roughly analogous to a header (`.h`)
file in C, in that it contains the relevant public information
about what the module provides. The other file is the object file
(`.o` extension) which can be linked with the run time to form an
executable.

We can now compile both the main program and the module to give an
executable.
```
$ ftn module1.o program1.f90
```
Again, by analogy with C header files, we do not include the `.mod`
file in the compilation command; there is a search path which the
compiler uses to look for module files (which includes the current
working directory).

> ## `.mod` files
>
> As stated, the `.mod` files are compiler specific. That means that you
> shouldn't expect that a file created by one compiler will be usable by a
> different compiler. This can be can cause compile time errors if you try to
> use a `.mod` from one compiler with another; perhaps the most common scenario
> for this is when testing builds with different compilers without first
> cleaning up the `.mod` files. Sometimes compilers also use different naming
> schemes for the `.mod` files can also change. This behaviour can usually be
> changed with compiler flags.
{: .callout}

### Exercise (2 minutes)

> ## Compiling modules
>
> If you haven't already done so, compile the accompanying
> [module1.f90](../exercises/08-modules/module1.f90) and
> [program1.f90](../exercises/08-modules/program1.f90). Check the errors which
> occur if you: (1) try to compile the program without the module file via,
> e.g.,
> ```
> $ ftn program1.f90
> ```
> and (2), if you try to compile and link the module file alone:
> ```
> $ ftn module1.f90
> ```
> 
> > ## Solution
> > 
> > Compiling the program alone produces (with the Cray compiler) the following error:
> > ```
> > 
> >   use module1
> >       ^
> > ftn-292 ftn: ERROR PROGRAM1, File = program1.f90, Line = 3, Column = 7
> >   "MODULE1" is specified as the module name on a USE statement, but the compiler cannot find it.
> > 
> >   real (kind = mykind) :: a
> >                ^
> > ftn-113 ftn: ERROR PROGRAM1, File = program1.f90, Line = 6, Column = 16
> >   IMPLICIT NONE is specified in the local scope, therefore an explicit type must be specified for data object "MYKIND".
> >                ^
> > ftn-868 ftn: ERROR PROGRAM1, File = program1.f90, Line = 6, Column = 16
> >   "MYKIND" is used in a constant expression, therefore it must be a constant.
> > 
> > Cray Fortran : Version 15.0.0 (20221026200610_324a8e7de6a18594c06a0ee5d8c0eda2109c6ac6)
> > Cray Fortran : Compile time:  0.0472 seconds
> > Cray Fortran : 13 source lines
> > Cray Fortran : 3 errors, 0 warnings, 0 other messages, 0 ansi
> > Cray Fortran : "explain ftn-message number" gives more information about each message.
> > ```
> > {: .output}
> > This tells us precisely that the compiler doesn't know what module we're talking about when we `use module1`, and then that
> > `mykind` (which we have been expecting to get from the module) doesn't exist either.
> >
> > Compiling `module1` alone gives the following output from the Cray compiler:
> > ```
> > /opt/cray/pe/cce/15.0.0/binutils/x86_64/x86_64-pc-linux-gnu/bin/ld: /usr/lib64//crt1.o: in function `_start':
> > /home/abuild/rpmbuild/BUILD/glibc-2.31/csu/../sysdeps/x86_64/start.S:104: undefined reference to `main'
> > ```
> > {: .output}
> > This is less immediately meaningful. The second line tells us that there's no function called `main` available.
> > This is because what we've compiled has no `program ... end program`. There's no program in there to start,
> > were we able to invoke it on the command line. In other words, a module alone doesn't make a program we can run.
> > 
> {: .solution}
{: .challenge}


## Scope

Entities declared in a module are, by default, available by use association,
that is, they are visible in program units which `use` the module. One can
make this scope explicit via the `public` and `private` statements.
```
module module1

  implicit none
  public

  integer, parameter :: mykind = kind(1.d0)

contains

  function pi_mykind() result(pi)

    real (kind = mykind) :: pi
    ...
  end function pi_mykind()

end module module1
```
Note that the parameter `mykind` is available throughout the module via
_host association_ (always).

An alternative would be to switch the default to `private`, and explicitly
add `public` attributes:
```
module module1

  implicit none
  private

  integer, parameter, public :: mykind = kind(1.d0)    ! visible via `use`
  integer, parameter         :: mypriv = 2             ! not visible via `use`

  public :: pi_mykind

contains
  function pi_mykind() result(pi)                      ! public
    ! ... may call my_private() ...
  end function pi_mykind

  subroutine my_private()                              ! private
    ...
  end subroutine
end module module1
```
Note that scope of the `implicit` statement also covers the whole module,
including sub-programs.


### Exercise (1 minute)

> ## Private modules
>
> Edit the accompanying [module1.f90]() to add a `private` statement and check the error if you try to compile `program1.f90`.
> 
> > ## Solution
> > 
> > Making the module `private` hides the `mykind` parameter it provide from the program. On compilation, `mykind` can't be found
> > in the scope of the program, and the compiler will complain that no such name exists.
> > 
> {: .solution}
{: .challenge}


## Module data and other horrors

It is possible to establish non-parameter data in the specification
section of a module. E.g.,
```
module module2

  implicit none
  integer, dimension(:), allocatable :: iarray
...
```
This course will argue that you should _not_ do so. There are a number
of reasons.

1. Any such data takes on the character of a global mutable object.
Global objects are generally frowned upon in modern software development.
2. Operations in module procedures on such data run the risk of being
neither thread safe nor re-entrant.

Even worse, variables declared with an initialisation in a module
sub-program, e.g.,
```
  integer :: i = 1
```
implicitly take on the Fortran `save` attribute. This means the variable is
placed in heap memory and retains its value between calls. (This is analogous to
a `static` declaration in C.) This is certainly neither thread-safe nor
re-entrant. Uninitialised variables appear on the stack (and disappear) as
expected.

For this reason it is the rule, rather than the exception, that variables
are not initialised at the point of declaration in Fortran.

We will look at alternative ways of establishing and moving data
as we go along.

## Scope again: `block`

It is not possible in Fortran to intermingle declarations and
executable statements. Specification statements must appear
at the start of scope before any executable statements. This
can lead to rather lengthy list of declarations at the start
of large routines.

It is possible to introduce a local scope which follows executable
statements using the `block` construct. Schematically:
```
   ... some computation ...
   block
     integer :: itmp                  ! in scope within the block only
     ... some more computation ...
   end block
   ... some more computation ...
```
This can be useful for introducing temporary variables which are only
required for the duration of a short part of a longer procedure.
In this way, it acts like `{ .. }` in C.


### Exercise (5 minutes)

> ## Return to Gauss-Legendre
>
> Return to your code for the approximation to pi via the Gauss-Legendre iteration
> (or use the template [exercise1.f90](../exercises/05-arrays/exercise1.f90) from
> the earlier episode on arrays). Using the examples above as a template, write a
> module to contain a function which returns the value so computed. Check you can
> use the new function from a main program.
> 
> > ## Solution
> > 
> > An example solution is provided in
> > [solution_program.f90](../exercises/08-modules/solutions/solution_program.f90)
> > and
> > [solution_module.f90](../exercises/08-modules/solutions/solution_module.f90).
> > 
> {: .solution}
{: .challenge}

> ## Module dependencies
> 
> Food for thought: can we have the following situation?
> ```
> module a
> 
>   use b
>   implicit none
>   ! content a ...
> end module a
> ```
> and
> ```
> module b
> 
>   use a
>   implicit none
>   ! content b ...
> end module b
> ```
> If not, why not?
>
> > ## Solution
> > 
> > This is a circular dependency: `a` depends on `b` depends on `a`. There is
> > no solvable dependency tree, and this is not allowed.
> > 
> {: .solution} 
{: .challenge}


{% include links.md %}
