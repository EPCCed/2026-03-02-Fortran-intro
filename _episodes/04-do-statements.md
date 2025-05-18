---
title: "Loops and loop control"
teaching: 10
exercises: 10
questions:
- "How can I make the program do work repeatedly?"
- "How can I have the program only do as much work as is required?"
objectives:
- "Learn how to use a `do` construct to execute a single block of code many times."
- "See how to have a `do` construct skip a loop with `cycle` or end early with `exit`."
- "Learn how to use loop control variables with `do` constructs."
keypoints:
- "Iteration in Fortran is based around the `do` construct (somewhat analogous to C `for` construct). There is no equivalent of the C++ iterator class."
- "Without any control, a `do` loop will execute forever."
- "A loop iteration can be skipped with a `cycle` statement."
- "A loop can be ended if an `exit` statement is encountered."
- "It is very common to control the execution of a loop with an `integer` variable."
---

## Uncontrolled `do` construct

A simple iteration is provided by the `do` statement. For example, ...
```
  do
    ! ... go around for ever ...
  end do
```
A slightly more useful version requires some control (see
[example1.f90](../exercises/04-do-statements/example1.f90)):
```
   integer :: i = 0
   do
     i = i + 1
     if (mod(i, 2) == 0) cycle    ! go to the next iteration
     if (i >= 10) exit            ! exit loop completely
     ! ... some computation ...
   end do

   ! ... control continues here after exit ...
```
Loop constructs may be nested, and may also be named (see
[example2.f90](../exercises/04-do-statements/example2.f90)):
```
  some_outer_loop: &
  do
    some_inner_loop: &
    do
      if (i >= 10) exit some_outer_loop  ! exit belongs to outer loop
      ! ... continues ...
    end do some_inner_loop
  end do some_outer_loop
```
If the control statements `cycle` or `exit` do not have a label,
they belong to the innermost construct in which they appear.


## Loop control

More typically, one encounters controlled iterations with an `integer`
loop control variable. E.g.,
```
  integer :: i
  do i = 1, 10, 2
    ! ... perform some computation ...
  end do
```
Formally, we have
```
[do-name:] do [loop-control]
             do-block
	   end do [do-name]
```
with _loop-control_ of the form:
```
  do-variable = int-expr-lower, int-expr-upper [, int-expr-stride]
```
and where the number of iterations will be
```
  max(0, (int-expr-upper - int-expr-lower + int-expr-stride)/int-expr-stride)
```
in the absence of any subsequent control. The number of iterations may
be zero. Any of the expressions may be negative. If the stride is not
present, it will be 1 (unity); if the stride is present, it may not be zero.

### Exercise (2 minutes)

> ## How many iterations make a do loop?
>
> What is the number of iterations in the following cases?
> ```
>    do i = 1, 10
>      print *, "i is  ", i
>    end do
>
>    do i = 1, 10, -2
>      print *, "i is ", i
>    end do
>
>    do i = 10, 1, -2
>      print *, "i is ", i
>    end do
> ```
> You can confirm your answers by running
> [example3.f90](../exercises/04-do-statements/example3.f90). Note there is no
> way (cf. C `for`) to limit the scope of the loop variable to the loop
> construct itself; the variable will then have a final value after exit from
> the loop.
> 
> > ## Solution
> > 
> > The following output is produced:
> > ```
> >  First loop: 1, 10
> >  i is  1
> >  i is  2
> >  i is  3
> >  i is  4
> >  i is  5
> >  i is  6
> >  i is  7
> >  i is  8
> >  i is  9
> >  i is  10
> >  Second loop: 1, 10, -2
> >  Third loop: 10, 1, -2
> >  i is  10
> >  i is  8
> >  i is  6
> >  i is  4
> >  i is  2
> > ```
> > {: .output}
> > The first loop has ten iterations with `i` running from 0 to 10 in steps of 1.
> > 
> > The second loop runs zero times as, with a stride of -2, there is no way to iterate from 1 to 10.
> >
> > The third loop has five iterations, from 10 to 2 in steps of -2. The stated
> > end value of 1 can't be reached, and 0 would go too far, so it finishes at 2.
> > 
> {: .solution}
{: .challenge}


### Exercise (5 minutes)

> ## Calculating pi with loops
>
> We return the exercises discussed in the earlier [episode on
> variables]({{page.root }}{% link _episodes/02-variables.md %}). You can use
> your own solutions, or the new template here.
>
> For [exercise1.f90](../exercises/04-do-statements/exercise1.f90) which
> computes an approximation to the constant pi using the Gauss-Legendre
> algorithm, introduce an iteration to compute a fixed number of successive
> improvements. How many iterations are required to converge when using
> `kind(1.d0)`? Would you be able to adjust the program to halt the iteration if
> the approximation is within a given tolerance of the true answer?
> 
> > ## Solution
> > 
> > Sample code implementing loops with this problem is used as a template to the
> > [exercise](../exercises/05-arrays/exercise1.f90) in the [episode on
> > arrays]({{ page.root }}{% link _episodes/05-arrays.md %}).
> > 
> > You should be able to observe that with `kind(1.d0)` the value of pi
> > converges after only three iterations. You also can have the code exit the
> > loop and halt iteration by storing the previous estimate of pi `if` the
> > difference between the old and new values is less than the desired
> > tolerance.
> > 
> {: .solution}
{: .challenge}


### Exercise (5 minutes)

> ## Conductance of a channel with loops
>
> [exercise2.f90](../exercises/04-do-statements/exercise2.f90) returns to the
> calculation of the conductance in the narrow channel and will need similar
> work. Use a loop to compute a fixed number of terms in the sum over index k
> (use real type `real64` for the sum). Here you should find convergence is much
> slower (you may need about 1000 terms); check by printing out the current
> value every so many terms (say 20).
>
> Expert question: What happens if you accumulate the sum in the reverse order
> in this case? Can you think why this happens?
> 
> > ## Solution
> > 
> > Answer to the expert question: floating point numbers of a given format
> > (such as `real64`) all have the same _relative error_, no matter how big or
> > small they are. The _absolute error_ on the other hand is the produce of the
> > number's value and the relative error; thus, a small `real` has a small
> > absolute error, and a large `real` has a large absolute error. If the large
> > numbers are summed first, the sum's absolute error quickly becomes large,
> > and the smaller numbers are subsumed into it. If the small numbers are
> > summed first, the sum's absolute error remains small enough that the small
> > numbers are able to contribute. Consider further how in floating point maths
> > it is true that `(x + y) + z /= x + (y + z)`, if you are interested look up
> > [Kahan's
> > algorithm](https://en.wikipedia.org/wiki/Kahan_summation_algorithm).
> > 
> {: .solution}
{: .challenge}


{% include links.md %}
