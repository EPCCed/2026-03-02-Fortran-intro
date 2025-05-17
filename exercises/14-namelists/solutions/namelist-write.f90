program namelist_write

  implicit none

  integer :: nmlunit

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
  open(nmlunit, file="config-out.nml", status = "new", action = "write")
  write(nmlunit, run)
  close(nmlunit)

end program namelist_write
