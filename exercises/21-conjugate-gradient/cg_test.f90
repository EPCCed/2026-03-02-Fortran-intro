program cg_test

  ! Conjugate gradient test problem

  ! Implement your solver in the cgradient module.
  use cgradient
  implicit none

  integer, parameter :: nmax = 4

  real (k_real), dimension(nmax, nmax) :: a
  real (k_real), dimension(nmax)       :: b
  real (k_real), dimension(nmax)       :: x
  real (k_real) :: tol = 0.0001
  integer :: ierr

  ! a must be symmetric
  a(1,:) = [ 4.0, 1.0, 0.0, 0.0 ]
  a(2,:) = [ 1.0, 4.0, 1.0, 0.0 ]
  a(3,:) = [ 0.0, 1.0, 4.0, 1.0 ]
  a(4,:) = [ 0.0, 0.0, 1.0, 4.0 ]

  b(:)   = [ 1.0, 4.0, 5.0, 6.0 ]

  ! initial guess
  x(:) = 1.0

  ! Call your solver here. You will need to provide as input
  ! both a and b as well as the initial guess at the solution, x.
  ! You should also specify a tolerance for the CG solver.
  ! On return from the solver, x should solve the problem Ax = b to
  ! within that tolerance.
  ! You can also have your solver return an error value. Think about
  ! what checks might be performed.

  call cg_solve(a, b, tol, x, ierr)

  ! Make sure everything went well by printing some values.
  ! We want to have an ierr of 0, and the original matrix A
  ! multiplied by the solution vector x should now equal b.

  print *, "ierr:    ", ierr
  print *, "Solution ", x(:)
  print *, "Check b:  ", matmul(a, x)


end program cg_test
