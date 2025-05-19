---
title: "Using namelists"
teaching: 20
exercises: 20
questions:
- "What is a namelist?"
- "How can I use a namelist to read and write grouped data?"
objectives:
- "Understand what a namelist is and how to create declare one."
- "Be able to read and write namelists from file."
- "Understand how namelists store structured data such as arrays and derived types."
keypoints:
- "Namelists are declared using the `namelist /namelist-group-name/ variable-name-list` construct."
- "Read and write namelists by passing them directly to the `read` and `write` statements."
- "Remember that namelists cannot be read out of order from a file without first moving backwards through the file."
---

# Fortran namelists

Fortran supports a special form of file I/O called namelists which enable the
grouping of variables for reading and writing.

## The namelist specification

The namelist associates a name with a list of variables. The namelist is
declared using a `namelist` construct which takes the form
```
  namelist /namelist-group-name/ variable-name-list
```
where the `namelist-group-name` is surrounded by forward slashes `/` and the
`variable-name-list` is a comma separated list of variables, e.g.:
```
  integer :: a, b, c
  namelist /ints/ a, b, c
```

## Namelists in a file

A namelist file is plain text and may contain one or more namelists. Each of
these is begun by `&namelist-group-name` and terminated by `/`. Variable-value
assignments occur in the body of the `namelist`, e.g. the file may contain
```
&ints
a = 1
b = 2
c = 3
/
```

The ordering of variables in the namelist does not matter, so the previous
example could also have been written as
```
&ints
c = 3
a = 1
b = 2
/
```

## Reading a namelist

A common usecase for namelists is to specify parameters for a program at
runtime. For example a simulation code might read its configuration from a
namelist called `run` as follows:
```
&run
name = "TGV" ! Case name
nsteps = 100 ! Number of timesteps
dt = 0.1     ! Timestep
/
```
As you can see, an extra nice feature of namelists is their support for
comments using the same `!` character as in Fortran code.

To read the namelist from a file, the `namelist-group-name` is passed as the
argument to `read()`, so in order to read this `run` namelist we might do the
following:
```
  integer :: myunit
  character(len=:) :: name
  integer :: nsteps
  real :: dt

  namelist /run/ name, nsteps, dt

  open(newunit = myunit, file = 'config', action = 'read', status = 'old')
  read(myunit, run)
  close(myunit)
```
Note that any variables not set in the `namelist` file will retain their initial
values.

### Exercise (5 minutes)

> ## Reading a namelist from file
>
> Using [namelist-read.f90](../exercises/14-namelists/namelist-read.f90), confirm
> that the runtime values can be specified by changing the contents of the
> namelist in [config.nml](../exercises/14-namelists/config.nml). Modify the
> program to specify a default value for `dt` and confirm that `dt` retains its
> value unless otherwise set in the `namelist`.
> 
> What happens if the value set is not of the same type as the variable
> specification in the program?
> 
> What happens if you add an unexpected value to the
> namelist?
> 
> > ## Solution
> > 
> > If the value in the namelist is not of the same type as the program's variable, you will
> > receive an error stating that it is mismatched.
> >
> > Any unexpected values will also trigger an error stating that the namelist object
> > cannot be matched to a variable.
> > 
> {: .solution}
{: .challenge}


### Reading multiple namelists

As stated earlier, we can have multiple namelists within a single file.
Continuing with our simulation example we might additionally want to specify
some numerical schemes for the simulation, e.g. adding the `schemes` namelist:
```
&run
name = "TGV" ! Case name
nsteps = 100 ! Number of timesteps
dt = 0.1     ! Timestep
/

&schemes
advection = "upwind"  ! Advection scheme
diffusion = "central" ! Diffusion scheme
transient = "RK3"     ! Timestepping scheme
/
```

We can read the values for each of these namelists as outlined previously, but
note, however that the order of the namelists themselves is important. After
reading a namelist the file reader will be positioned at its end, and trying to
read a namelist that occurred previously in the file will fail. Either the
reading subroutine must match the order of the namelists which occur in the
file or file motion calls such as `rewind()` should be used to ensure that
reading is independent of order.

### Exercise (5 mins)

> ## Reading multiple namelists
>
> Extend the example program
> [namelist-read.f90](../exercises/14-namelists/namelist-read.f90) to read the
> numerical `schemes` namelist from
> [config-full.nml](../exercises/14-namelists/config-full.nml).
> 
> (Optional) Ensure that your program can read the `run` configuration and the
> numerical `schemes` regardless of the order in which they appear.
> 
> > ## Solution
> > 
> > Add some `character` variables to store the items from the `schemes` namelist,
> > declare the namelist itself with those variables, then, after reading the `run`
> > namelist, read `schemes`. To make sure it can read the two schemes in any order,
> > do a `rewind(nmlunit)` in between them. This way, you read through to the first
> > namelist, reset position to the start, then read through to the second.
> >
> > If they are in the wrong order and you don't do this, you will encounter an
> > end of file error.
> > 
> {: .solution}
{: .challenge}


## Writing a namelist

Writing a namelist works similarly to reading one. With an open file, or other
output device, passing the namelist as the argument to `write()` will write the
namelist to the file.
```
  integer :: myunit
  integer :: a, b, c
  namelist /ints/ a, b, c

  a = 1
  b = 2
  c = 3

  open(newunit = myunit, file = 'output.nml', action = 'write', status = 'new')
  write(myunit, ints)
  close(myunit)
```
will output the following to the new file `output.nml`:
```
&INTS
 A=1          ,
 B=2          ,
 C=3          ,
 /
```

### Exercise (10 minutes)

> ## Writing namelists to file
>
> Write a program to write the simulation parameters as a namelist so that it can
> be read by the previous example program.
>
> (Optional) If you completed the extension to read the namelists in any order,
> confirm that this works with your new program when writing in any order.
> 
> > ## Solution
> > 
> > A solution writing the `run` namelist can be found in
> > [namelist-write.f90](../exercises/14-namelists/solutions/namelist-write.f90).
> > 
> {: .solution}
{: .challenge}


## Handling complex data

So far we have only considered simple scalars and strings, but namelists also
support I/O of more complex data structures such as arrays or user-defined
types. These are handled similarly to the code we have seen so far.

### Exercise (10 minutes)

> ## Writing complex data to namelists
>
> An example program
> [namelist-complex.f90](../exercises/14-namelists/namelist-complex.f90) is
> provided to write more complex data structures to a namelist. Try running this
> program and inspecting the output to see how these data structures are
> represented.
>
> Modify the program to read the namelist back into data and confirm that the data
> is correct, for example by testing array elements match their expected values.
>
{: .challenge}


{% include links.md %}
