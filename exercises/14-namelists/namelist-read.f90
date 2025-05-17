program namelist_read

  implicit none

  integer :: nmlunit
  character(len=128) :: name
  integer :: nsteps
  real :: dt
  namelist /run/ name, nsteps, dt

  ! Get the run configuration from file
  open(newunit = nmlunit, file="config.nml", status = "old", action = "read")
  read(nmlunit, run)
  close(nmlunit)

  ! Print the run configuration
  print *, "Case Name: ", trim(name)
  print *, "nSteps: ", nsteps
  print *, "Time Step: ", dt

end program namelist_read
  
