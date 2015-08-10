  program expand_2D_to_3D
    !!
    !! IMPORTANT THE AXISEM OUTPUT IS IN SINGLE PRECISION
    !!
    !!
    !use interp_mod        !! interpolation
    use mpi_mod
    use reading_inputs     !! reading input parameters
    use reading_field      !! reading field
    use post_processing    !! do the post-process stuff (cf Tarje's papers)
    !use writing_output    !! write the output interpoled wave field
    integer isim

    call init_mpi()
    isim=1
    ! read point where we need to compute solution
    if (myrank==0) then
      call read_info_simu(nsim) 
      write(*,*) 'M0 before read_inputs '
      call read_inputs(isim)
      write(*,*) 'M0 after read_inputs '

      ! read gll point coordinate
      call read_mesh(isim)

      write(*,*) 'M0 after read_mesh '
      ! find elements and coordinate for each input point
      call connect_points()

      write(*,*) 'M0 after connect_points '
    endif
    call barrier_mpi()
    write(*,*) 'Before mpi', myrank
    call alloc_all_mpi()
    write(*,*) 'after alloc mpi', myrank
    call bcast_all_mpi()
    write(*,*) 'after bcast ', myrank
    call distrib_mpi()  !! to do : faire directement la distrib sur les memes procs que Specfem

    write(*,*) 'After mpi', myrank 
    do isim=1,nsim  !! do to : mettre en memoire la solution sous echantillonnee et la resampler avant de l'ecrire
     ! interpolation of the velocity field in each point
     call read_veloc_field_and_interpol(isim)

     ! interpolation of the stress in each point
     call read_stress_field_and_interpol(isim)
    enddo

    call finalize_mpi()

  end program expand_2D_to_3D