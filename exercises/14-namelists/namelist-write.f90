program namelist_write

  implicit none

  ! Declare variables
  character(len=:), allocatable :: name
  integer :: nsteps 
  real :: dt
  namelist /run/ name, nsteps, dt

  ! Initialise variables
  name = "TGV"
  nsteps = 100
  dt = 0.1

  ! Write data to namelist
  open(101, file="config-out.nml")
  write(101, run)
  close(101)

end program namelist_write
