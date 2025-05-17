module types

  implicit none

  type mytype
     integer :: a
     real :: b
  end type mytype
  
end module types

program namelist_complex

  use types
  
  implicit none

  integer :: nmlunit

  integer, dimension(5) :: a
  type(mytype) :: b
  namelist /comp/ a, b

  integer :: i

  ! Initialise variables
  do i = 1, 5
     a(i) = i
  end do
  b%a = 42
  b%b = 3.14

  ! Write data to namelist
  open(newunit = nmlunit, file="complex.nml", status = "new", action = "write")
  write(nmlunit, comp)
  close(nmlunit)

end program namelist_complex
  
