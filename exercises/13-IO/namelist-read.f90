program namelist_read

  implicit none

  character(len=128) :: name
  integer :: nsteps
  real :: dt
  namelist /run/ name, nsteps, dt

  ! Get the run configuration from file
  open(101, file="config.nml")
  read(101, run)
  close(101)

  ! Print the run configuration
  print *, "Case Name: ", trim(name)
  print *, "nSteps: ", nsteps
  print *, "Time Step: ", dt

end program namelist_read
  
