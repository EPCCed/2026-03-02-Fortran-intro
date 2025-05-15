---
title: "Using namelists"
teaching:
exercises:
questions:
- ""
objectives:
- ""
keypoints:
- "Using Fortran namelists for I/O."
---

# Fortran namelists

Fortran supports a special form of file I/O called `namelist`s, these enable grouping variables
together for reading and writing.

## The namelist specification

The `namelist` associates a name with a list of variables, this takes the form
```
namelist /namelist-group-name/ variable-name-list
```
where the `name-list-group-name` is surrounded by forward slashes `/` and the `variable-name-list`
is a comma separated list of variables, for example
```
integer :: a, b, c
namelist /ints/ a, b, c
```

## Namelists in a file

A `namelist` file may contain one or more namelists, these are indicated by `&namelist-group-name`
and terminated by `/`.
Variable-value assignments occur in the body of the `namelist`, for example
```
&ints
a = 1
b = 2
c = 3
/
```

The ordering of variables in the name list does not matter, the previous example could also have
been written as
```
&ints
c = 3
a = 1
b = 2
/
```

## Reading a namelist

A common usecase for `namelists` is to specify parameters for a program at runtime, for example a
simulation code might read its configuration from a `namelist`
```
&run
name = "TGV" ! Case name
nsteps = 100 ! Number of timesteps
dt = 0.1     ! Timestep
/
```
a nice feature of `namelist`s for input files is their support for comments using the `!`.

To read the `namelist` from a file, the `namelist-group-name` is passed as the argument to `read()`,
for example
```
character(len=:) :: name
integer :: nsteps
real :: dt

namelist /run/ name, nsteps, dt

open(101, "config")
read(101, run)
close(101)
```
Note that any variables not set in the `namelist` file will retain their initial values.

### Exercise (5 minutes)

Using the provided example program, confirm that the runtime values can be specified by changing the
contents of the `namelist`.
Modify the program to specify a default value for `dt` and confirm that `dt` retains its value
unless otherwise set in the `namelist`.

What happens if the value set is not of the same type as the variable specification in the program?
What happens if you add an unexpected value to the namelist?

### Reading multiple namelists

As stated earlier, we can have multiple namelists within a file.
Continuing our simulation example we might additionally want to specify some numerical schemes for the simulation
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

and we can read the values for each `namelist` as outlined previously.
Note, however that the order of the `namelist`s themselves is important.
After reading a `namelist` the file reader will be positioned at its end, and trying to read a
`namelist` that occurred previously in the file will fail.
Either the reading subroutine must match the order wich `namelist`s occur in the file, or file
motion subroutines such as `rewind` should be used to ensure reading is independent of order.

#### Exercies (5 mins)

Extend the example program to read the numerical `schemes` namelist.

(Optional) ensure that your program can read the `run` configuration and the numerical `schemes`
regardless of the order in which they appear.
