---
title: "Hello World"
teaching: 10
exercises: 10
questions:
- "What is the structure of a Fortran program?"
- "How do I print output from the program to the terminal?"
objectives:
- "Write, compile and run a simple Fortran program."
- "Understand how to use the `print` and `write` statements.`"
- "Load the `iso_fortran_env` module with a `use` statement."
keypoints:
- "A Fortran program begins with a `program` statement and ends with an `end program` statement."
- "A `print` statement is a simple way to write output to the terminal."
- "A `write` statement provides more control including ways to write to file."
- "Modules can be loaded with the `use` statement."
- "The `iso_fortran_env` module provides symbols which can be used to help read from and write to the terminal."
---

## First example

A very simple program might be:
```
program example1

  ! An example program prints "Hello World" to the screen

  print * , "Hello World"

end program example1
```

Formally, a Fortran program consists of one or more lines made up of
Fortran _statements_. Line breaks are significant (e.g., there are
no semi-colons `;` required here).

Comments are introduced with an exclamation mark `!`, and may trail
other statements.

The `program` statement is roughly doing the equivalent job of `main()`
in C/C++. However, note there is not (and must not be) a return statement.

### Exercise (1 minute)

> ## Compile your first program
>
> Check now you can compile and run the first example program
> [example1.f90](../exercises/01-hello-world/example1.f90). What
> output do you get when you run it?
>
> > ## Solution
> > 
> > Compile and run the program on ARCHER2 as follows:
> > ```
> > ftn example1.f90
> > ./a.out
> > ```
> > {: .source}
> > which will give the following output:
> > ```
> >  Hello world
> > ```
> > {: .output}
> > 
> {: .solution}
{: .challenge}

### Formal description

```
  [ program [program-name] ]
     [ specification-part ]
     [ executable-part ]
  [ contains
     internal-subprogram-part ]
  end [program-name]
```
Optional components are represented with square brackets `[...]`. It
follows that the shortest standard-conforming program will be (see
[example2.f90](../exercises/01-hello-world/example2.f90)):
```
end
```
If the `program-name` is present, it must be at both the beginning and
the end, and must be the same in both places.

We will return to the `contains` statement in the context of modules.

## `print` statement

In general
```
  print format [ , output-item-list ]
```
where the `format` is a format specifier (discussed later) and the
`output-item-list` is a comma-separated list of values/variables
to be printed to the standard output.

If the format is a  `*` (a so-called free-format) the implementation
is allowed to apply a default format for a given type of item.


## Alternative

Consider the following program (available as [example3.f90](../exercises/01-hello-world/example3.f90)):
```
program example3

  use iso_fortran_env, only : output_unit

  write (output_unit, *) "Hello ", "world"

end program example3
```

This example shows a more general way to provide some output. Here we are
also going to employ the `use` statement to import a symbol from the
(intrinsic) module `iso_fortran_env`. The symbol is `output_unit` which
identifies the default standard output (cf. `stdout`).


### `use` statement

Formally,
```
  use [[ , module-nature] ::] module-name [ , only : [only-list]]
```
If `module-nature` is present, it must be either `intrinsic` or
`non_intrinsic`. The implementation must provide certain intrinsic
modules such `iso_fortran_env`. You can write modules of your own, as
we will see later on.

There is no formal namespace mechanism in Fortran (cf. C++), so
restrictions on which symbols are visible can be made via an optional
`only-list`. If there is no `only-list` then all the public symbols
from `module-name` will be visible.


### `write` statement

Formally,
```
  write (io-control-spec-list) [output-item-list]
```
where the `output-item-list` is a comma separated list of items to
be output. The `io-control-spec-list` has a large number of potential
arguments (again comma separated). For formatted output, these must
include at least a unit number and a format:
```
  write ([unit = ] io-unit, [fmt = ] format) [output-item-list]
```
where the `io-unit` is a valid integer unit number, and the `format`
is a format-specifier (as for `print`).

Examples are
```
  write (unit = output_unit, fmt = *)
  write (output_unit, *)
  write (*, *)
```
C programmers looking for a new-line like symbol will notice that none
has appeared so far. The default situation is that both `print` and
`write` generate a new-line automatically. The `*` symbol in the context
of `io-unit` is a default output unit (usually the screen).

We will return to the `write` statement and format-specifiers in more
detail in the context of i/o to external files.

## Some comments on style

Modern Fortran is not case sensitive. Older versions required capitals,
a style which has persisted to the present day in some places. So you
may see things such as
```
PROGRAM example1

  PRINT *, "Hello World"

END PROGRAM example1
```
As modern etiquette tends to regard capitals as shouting, this can cause
some tension.

The compiler will accept mixed case. An additional tool would be required
to enforce a particular style.

This course will prefer an all lower-case style.

### Exercise (2 minutes)

> ## Check symbol values
>
> Write a program which prints out the actual values of the symbols
> `output_unit`, `error_unit`, and `input_unit`
> (all from `iso_fortran_env`) to the screen.
>
> If you haven't used the `only` clause in your `use iso_fortran_env`,
> add it now. What happens to the results if you miss out one of the
> symbols referenced from the `only` clause? This behaviour will be
> explained in the following section.
>
> Bonus: check the values using both the Cray and GCC compilers. On
> ARCHER2 both are invoked with the `ftn` compiler wrapper. Which
> compiler is actually used depends on the `PrgEnv-` module loaded.
> 
> > ## Solution
> > 
> > Make sure to `use` the module, then use `print *` statements to write the
> > values of the three symbols to the screen. Sample solution code is available
> > in [exercise1.f90](../exercises/01-hello-world/solutions/exercise1.f90).
> > 
> > Running with the default Cray compiler gives the output:
> > ```
> >  output_unit is:  101
> >  error_unit is:   102
> >  input_unit is:   100
> > ```
> > {: .output}
> > while using `gfortran` from GCC gives:
> > ```
> >  output_unit is:            6
> >  error_unit is:             0
> >  input_unit is:             5
> > ```
> > {: .output}
> > 
> {: .solution}
{: .challenge}

{% include links.md %}
