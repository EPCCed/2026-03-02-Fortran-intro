module cgradient

  ! Conjugate gradient example
  ! We we use the real kind k_kind

  implicit none

  integer, parameter :: k_real = kind(1.e0)

contains

  subroutine cg_solve(a, b, tol, x, ierr)

    ! The initial guess x will be replaced by the solution on exit

    real (k_real), dimension(:,:), intent(in)    :: a     ! matrix
    real (k_real), dimension(:),   intent(in)    :: b     ! rhs
    real (k_real),                 intent(in)    :: tol   ! tolerance
    real (k_real), dimension(:),   intent(inout) :: x
    integer,                       intent(out)   :: ierr

    ! Implement your solver here.

  end subroutine cg_solve

end module cgradient
