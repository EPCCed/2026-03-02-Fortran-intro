---
title: "Formats and edit descriptors"
teaching: 10
exercises: 10
questions:
- "How do I read input from the keyboard to my program?"
- "How can I control the format of input and output of various types?"
objectives:
- "Use the `read` statement analogously to `write` to obtain input from the keyboard."
- "Learn how to combine edit descriptors to create a format specifier."
- "Use format specifiers to control the appearance of output of the various types we have encountered."
keypoints:
- "Control over the appearance of output is via the format specifier, which is a string."
- "This similar in spirit to the format string provided to `printf()` in C."
- "The use of a format allows predictable tabulation of output for human readers."
---

## Input and output

So far we have seen only output (via either `print` or `write`). Input
is via the `read` statement.
```
  use :: iso_fortran_env
  ...
  read (unit = input_unit, fmt = *) var-io-list
```
In very many respects, `read` looks much like `write`, in that it
takes the same arguments, including unit number and format specifier.
However, whereas `write` may have an I/O list involving expressions, `read`
must have only the variables which will store the incoming values.

The standard input unit (`input_unit` from `iso_fortran_env` in the above)
is typically the keyboard (or "screen") for interactive use.

## Format specifier

In addition to the _list-directed_ or free-format `*` specifier, a
format may be a string literal, a fixed character parameter, or a
string constructed at run time. Some examples are:
```
   read (*, *) var             ! read using list-directed, or free format
   print '(a)', "A string"     ! character literal '(a)'
   write (*, myformat) var     ! character variable (or parameter)
   write(unit = myunit) var    ! unformatted (no format)
```

Output with a format specifier, either string or `*`, is referred to as
_formatted_ I/O. This is to distinguish it from _unformatted_ I/O; this is
essentially a direct dump of the binary internal representation. For unformatted
I/O the format specifier is simply omitted.

Binary output can have its uses, but more portable and flexible methods
of "fast" output are probably to be preferred (e.g., via a library such
as HDF5). We will not consider unformatted output any further in this course.


## Edit descriptors

A format specifier consists of a comma-separated list of
_edit descriptors_ enclosed in parentheses. The edit descriptors
determine how the internal representation of data is translated or converted
to characters which can be displayed.

The formal and exhaustive statement of exactly what is allowed in an
edit descriptor is rather, well, exhausting. It is easier to consider
some common examples of the three different types of descriptor.

### Data edit descriptors

Data edit descriptors feature a single character describing the type
data format wanted, and a literal integer part indicating the total
field width, and number of decimals. These include
```
  iw        ! integer width w characters
  fw.d      ! floating point number total width w and d decimal characters
  ew.d      ! scientific notation with total width w and d decimal characters
  aw        ! character string total width w
```
The width is the total width of the field, and must be wide enough to
accommodate any leading signs, decimal points, or exponents. Where there
is a _w.d_ the _d_ indicates the number of digits to appear after the
decimal point.

Data edit descriptors should correspond to the relevant item in the _io-list_,
based on position. Some simple examples are:
```
  integer :: ivar = 40
  real    :: avar = 40.0
  print "(  i10)", ivar           ! produces "40" with 8 leading spaces
  print "(f10.3)", avar           ! produces "40.000" with 4 leading spaces
  print "(e10.3)", avar           ! produces "0.400e+02" with 1 leading space
```
For scientific notation, the exponent will appear either with two digits
("E+_dd_" or "E-_dd_"), or three digits for exponents greater than 99
("+_ddd_" or "-_ddd_").

If a first significant digit is required before the decimal point in
scientific notation (instead of a zero) the `es` edit descriptor can
be used instead of `e`; otherwise it's the same.

An engineering edit descriptor `en` is available. It also acts like a standard
`e` descriptor, but exponents are limited to a subset ...,-3,0,+3,+6,...,
corresponding to standard SI prefixes milli-, kilo-, mega-, and so on.
There will be an appropriate movement in the decimal point.

If an exponent greater than 999 is required, an optional `e` descriptor for
the exponent itself is available:
```
  print "(e14.3e4)", avar         ! Use at least 4 digits in exponent
```

Note that an integer descriptor is allowed to be of the form _iw.d_,
in which case leading zeros are added to pad to the width _w_, if
required.

### Character string edit descriptors

One can use a string literal as part of the edit descriptor itself, e.g.,
```
  real :: avar = 4.0
  print "('This is the result: ', e14.7)", avar
```

### Control edit descriptors

There are a number of these. They do not correspond to an item in the
_io-list_, but alter the appearance of the output. The most common is
`x` which introduces a space (or blank). E.g.,
```
   print "(i12,x,e12.6)", ivar, avar
```
This will ensure at least one space between the two items in the list.

If a leading plus sign is wanted, use the `sp` control, e.g.:
```
  print "(sp,e12.6)", abs(avar)
```

### Exercise (2 minutes)

> ## Exercise name
>
> Compile and run the accompanying
> [example1.f90](../exercises/12-read-write/example1.f90) program, which provides
> some specimen formats. Some of the format specifiers have not been allowed a
> large enough width. What's the result? What's the solution?
> 
> > ## Solution
> > 
> > Using gfortran produces the following output:
> > ```
> > Format i10:            40
> > Format i10.10: 0000000040
> > Format l10:             F
> > Format f10.3:      40.000
> > Format e10.3:   0.400E+02
> > Format en10.3: 40.000E+00
> > Format a10:    Hello
> > Format i1:     *
> > Format f10.3:  **********
> > Format e10.3:   0.180+309
> > Others:
> > Format sp,e12.3:   +0.180+309
> > Format e12.3e4:   0.180E+0309
> > ```
> > {: .output}
> >
> > Where the format specifiers are too narrow, the output is reduced to
> > asterisks `*` in the space that has been provided. To fix this, the
> > specifiers need to be widened. For example, the integer specifier on line
> > 25 is `i1`, clearly not enough to print `-40.` Making it `i3` allows it to
> > output.
> >
> > The next failed output uses `f10.3`. It's trying to print a `huge()` number,
> > where it was used to store the largest possible number of the same type as
> > the original `avar`. As a `real64`, that's approximately `1.80E+308`. The
> > format specifier provides a width of 10 characters to print a number with
> > 309 digits (although we only have precision in the first 15 or so). The `f`
> > format specifier is very definitely unsuitable; one of the `e` types such as
> > `es24.17` is much more appropriate.
> > 
> {: .solution}
{: .challenge}


## Repeat counts

For a larger number of items of the same type, it can be useful to specify a
_repeat count_. Simply place the items to be repeated within parentheses and
prefix a literal integer count to the format, e.g.:
```
   real, dimension(4) :: a = [ 1.0, 2.0, 3.0, 4.0]

   print "(4(2x,e14.7))", a(1:4)
```
Multiple subformats are comma-separated, much like the individual items, and
subformats can also be nested. In this way, more complex formats can be
constructed.

### Complex variables

Variables of `complex` type are treated as two `real` values for the
purposes of a format specifier. The real and imaginary part do not have to
have the same edit descriptor.

### Logical variables

A "safe" (portable) minimum width for an `l` (logical) edit descriptor is
7 characters to accommodate "`.false.`", although some implementations
may only produce an `F`.

## New lines

If no new line at all is wanted, one can use the `advance = no` argument
to `write()`, e.g.:
```
  write (*, "('Input an integer: ')", advance = 'no')
  read (*, *) ivar
```
Non-advancing output must not use list-directed I/O.

## Statement labels

Formally, a format specifier may also be a _statement label_. For example,
```
   write (unit = myunit, fmt = 100) ia, ib, c

100 format(i3, i3, f14.7)
```
Here, the statement at the line with label `100` is the `format` keyword,
which may be used to define a format specifier.
This is very common in older forms of Fortran. However, as the reference
and the statement can become widely separated, this can be troublesome.
However, statement labels are useful in other contexts, as we will see
when we come to error handling.


## Exercise (5 minutes)

> ## Experimenting with formats
>
> Using the [example1.f90](../exercises/12-read-write/example1.f90) program, check
> what happens if there is a mismatch between the format specifier and the data
> type in the I/O list. Choose an example, and run the program.
>
> What happens if the number of items in the io-list is larger than
> the number of edit descriptors?
> 
> Additional exercise. The `b` edit descriptor can be used to convert integer
> values to their binary representation. For a 32-bit integer type, the
> recommended descriptor would be `b32.32` to ensure the leading zeros are
> visible. You may wish to try this out.
> 
> > ## Solution
> > 
> > Using the wrong type variable with a format specifier should still allow the
> > code to compile, but you will receive a runtime error when it is
> > encountered.
> >
> > Any extra items in the io-list above what the format provides will not be printed.
> > 
> {: .solution}
{: .challenge}


{% include links.md %}
