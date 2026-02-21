---
title: 'Exercises: conjugate gradient and matrices'
teaching: 10
exercises: 50
---

::::::::::::::::::::::::::::::::::::::: objectives

- Write a conjugate gradient solver.
- Read a Matrix Market Exchange file and plot a downloaded matrix.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: questions

- How can I really push what I've learnt so far?

::::::::::::::::::::::::::::::::::::::::::::::::::

## Exercises

To finish things off, here are two fairly substantial exercises you can tackle
which should put everything you've learnt to the test.

:::::::::::::::::::::::::::::::::::::::  challenge

## Conjugate gradient solver

Contrasting with the very specific tri-diagonal solver we've been working on,
the conjugate gradient method provides a slightly more general method for the
solution of linear systems

$Ax = b$

where the matrix $A$ is symmetric positive definite. The algorithm is explained in detail on
[Wikipedia](https://en.wikipedia.org/wiki/Conjugate_gradient_method), and if you
are very interested you might like to read [An Introduction to the Conjugate
Gradient Method Without the Agonizing
Pain](https://www.cs.cmu.edu/~quake-papers/painless-conjugate-gradient.pdf).

However, it is not necessary to understand the details, as here we are just
interested in implementing the algorithm.

There are two main steps involved. The first is to perform a
matrix-vector multiplication. This can be done using the Fortran
intrinsic function `matmul()`. (Or you can have a go at
implementing your own version - it's not too difficult.)

The second step is to compute a scalar residual from a vector
residual. If we have an array (vector) `r(1:n)` this can be
done with:

```fortran
  residual = sum(r(:)*r(:))
```

All the operations in the algorithm can be composed of these,
as well as vector additions and multiplications by a scalar.

A template program [cg\_test.f90](files/exercises/21-conjugate-gradient/cg_test.f90)
is provided with a small matrix to use as a test. You need to implement a module
`cgradient` which supplies a function `cg_test()` taking the arguments set out
in the template.

Remember that you can always check your answer by multiplying out
$Ax$ to recover the original right-hand side $b$.

:::::::::::::::  solution

You can check a suggested solution with
[cg\_test.f90](files/exercises/21-conjugate-gradient/solutions-1/cg_test.f90)
and
[cgradient\_solution.f90](files/exercises/21-conjugate-gradient/solutions-1/cgradient.f90).

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::  challenge

## Storage of large sparse matrices

The [Matrix Market](https://math.nist.gov/MatrixMarket/) provides a number of
archived matrices of different types. It also defines a simple ASCII format for
the storage of sparse matrices.

The Matrix Market Exchange format `.mtx` files are structured as
follows.

```output
%% Exactly one header line starting %%
% Zero or more comment lines starting %
nrows ncols nnonzero
i1 j1 a(i1,j1)
i2 j2 a(i2,j2)
...
```

where `nrows` and `ncols` are the number of rows and columns in the
matrix, respectively. `nnonzero` is the number of non-zero entries
in the matrix. For each non-zero entry there then follows a single
line which contains the row index, the column index, and the value of the
matrix element itself.

Download an example, e.g.,

```bash
$ wget https://math.nist.gov/pub/MatrixMarket2/Harwell-Boeing/laplace/gr_30_30.mtx.gz
$ gunzip gr_30_30.mtx
```

If you look at the first few line of this example, you should see

```output
%%MatrixMarket matrix coordinate real symmetric
900 900 4322
1 1  8.0000000000000e+00
2 1 -1.0000000000000e+00
31 1 -1.0000000000000e+00
32 1 -1.0000000000000e+00
2 2  8.0000000000000e+00
```

- Define a type that can hold the sparse representation
  and provide a procedure which initialises such a type from a
  file.

- Provide a procedure which brings into existence a dense matrix
  (just a two-dimensional array) initialised with the correct non-zero
  elements.

- Use the `.pbm` file generator to produce an image of the non-zero
  elements to provide a check the file has been read correctly.

- Try some other matrices from the Matrix Market.

:::::::::::::::  solution

## Solution

A suggested solution in provided in
[mmtest.f90](files/exercises/21-conjugate-gradient/solutions-2/mm_test.f90) and
[mmarket.f90](files/exercises/21-conjugate-gradient/solutions-2/mmarket.f90).

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::



:::::::::::::::::::::::::::::::::::::::: keypoints

- Fortran performance and array handling make it ideal for the solution of intense problems.

::::::::::::::::::::::::::::::::::::::::::::::::::


