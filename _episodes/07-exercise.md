---
title: "Mini exercise: a choice of two"
teaching: 10
exercises: 50
questions:
- "What are some real problems I can try out?"
objectives:
- "Work on one of two larger exercises, putting your new skills to use."
keypoints:
- "With a fairly small amount of the Fortran language, you can already solve some real problems."
---

## A choice...

We have two exercises you can choose to work on now. Both will allow you to make
use of the Fortran that you have learnt today. The former exercise is the
solution of a tri-diagonal system of equations, while the latter will allow you
program an implementation of Conway's Game of Life.

Whichever you choose (or if you choose both), we have time this afternoon and
tomorrow for you to work on your solutions.

> ## Solve a tri-diagonal system (30 minutes)
>
> This exercise will solve a tri-diagonal system of equations. A linear system of
> equations can be represented by the problem `Ax = b` where `A` is a known
> matrix, `b` is a known vector, and `x` is an unknown vector we wish to solve for.
> `A` is tri-diagonal, meaning that it is 0 everywhere except for a stripe of non-zeroes
> three-elements wide moving down the diagonal.
>
> This means that we can represent an `n`-by-`n` tri-diagonal matrix using three
> rank-1 arrays, one of size `n` representing the diagonal and two of size `n-1`
> representing the upper and lower diagonals. Through two operations across the
> arrays, the first moving forwards and the second backwards, as described
> at [Wikipedia](https://en.wikipedia.org/wiki/Tridiagonal_matrix_algorithm),
> the solution `x` can be determined.
>
> The accompanying template
> [tri-diagonal.f90](../exercises/07-exercise/tri-diagonal.f90) has some further
> instructions, and some suggestions on how to test the result.
> 
> > ## Solution
> > 
> > A solution to the problem appears as a
> > [template](../exercises/10-dummy-array-arguments/exercise.f90) to the
> > exercise in the [later episode on dummy arguments]({{ page.root }}{% link _episodes/10-dummy-array-arguments.md %}).
> > 
> {: .solution}
{: .challenge}


> ## Game of Life (60 minutes)
>
> In this exercise you will create a simple implementation of
> [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).
> The Game of Life is a _cellular automata_ model where an array of cells is
> updated based on some simple
> [rules](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life#Rules)
> which give rise to complex patterns.
>
> This model uses a 'board' of cells, each cell having a value of 0 ("dead") or 1
> ("alive"). The board's initial state is chosen and then stepped forwards. In a
> new step, each cell calculates the sum of the surrounding eight cells. Depending
> on the value of that sum, the cell's state may change or stay the same. The
> rules governing the update are summarised in the following table:
>
> | Cell state   | Sum of neighbouring 8 cells     | New Cell state |
> | ------------ | ------------------------------- | -------------- |
> | 0            | 0,1,2,4,5,6,7,8                 | 0              |
> | 0            | 3                               | 1              |
> | 1            | 0,1                             | 0              |
> | 1            | 4,5,6,7,8                       | 0              |
> | 1            | 2,3                             | 1              |
>
>
> A template [life.f90](../exercises/07-exercise/life.f90) is provided with some
> hints to get you started.
>
> ### Reference
>
> Your program should produce the following output for the initial
> board and the first update:
>
>```
> $ ./a.out
>  Initial Board Set-up:
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  ........#.#.#........
>  ........#...#........
>  ........#...#........
>  ........#...#........
>  ........#.#.#........
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>
>  First iteration:
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .........#.#.........
>  .......##...##.......
>  .......###.###.......
>  .......##...##.......
>  .........#.#.........
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
>  .....................
> ```
> 
> > ## Solution
> > 
> >  Two reference answers are given in the `solutions` directory. The
> >  [first](../exercises/07-exercise/solutions-1/life-step2.f90) only computes
> >  the first update, while the
> >  [second](../exercises/07-exercise/solutions-1/life-step3.f90) includes the
> >  time stepping loop.
> > 
> {: .solution}
{: .challenge}


{% include links.md %}
