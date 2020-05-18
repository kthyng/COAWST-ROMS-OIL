#include "cppdefs.h"
      MODULE mod_floats
#ifdef FLOATS
!
!svn $Id: mod_floats.F 830 2017-01-24 21:21:11Z arango $
!================================================== Hernan G. Arango ===
!  Copyright (c) 2002-2018 The ROMS/TOMS Group                         !
!    Licensed under a MIT/X style license                              !
!    See License_ROMS.txt                                              !
!=======================================================================
!                                                                      !
!  Findex     Indices of spherical coordinates entries in initial      !
!               location arrays, if any.                               !
!  Flon       Initial longitude locations, if any.                     !
!  Flat       Initial latitude locations, if any.                      !
!  Ftype      Float trajectory type:                                   !
!               Ftype(:) = 1,  neutral density 3D Lagrangian           !
!               Ftype(:) = 2,  isobaric (constant depth) float.        !
!  Tinfo      Float trajectory initial information.                    !
!  bounded    Float bounded status switch.                             !
# if defined SOLVE3D && defined FLOAT_VWALK
!  rwalk      Normally distributed random deviates used in vertical    !
!               random walk.                                           !
# endif
# if defined SOLVE3D && defined FLOAT_STICKY
!  stuck      Reflection switch. Floats that hit the surface are       !
!               reflected and floats that hitthe bottom get stick      !
# endif
# ifdef FLOAT_OIL
!  frroil0     Initial oil density by components                       ! DDMITRY
!             n components is  = Nocmp 
!            currently: (saturates, aromatics, res+asph                !
!             (rho1, rho2,rho3)                                        !
!  wfroil0     Initial oil component fractions                         !
!             n components is  = Nocmp  (saturates, aromatics, res+asph!
!             (fr1,fr2,fr3)                                            ! 
!  szoil0      Initial oil droplet size (needed to calc vol&mass)      ! 
!                                                                      ! END DD
# endif
!  track      Multivariate float trajectory data at several time       !
!               time levels.                                           !
!                                                                      !
!=======================================================================
!
        USE mod_param
!
        implicit none
!
!-----------------------------------------------------------------------
!  Lagrangian drifters (floats) structure.
!-----------------------------------------------------------------------
!
        TYPE T_DRIFTER

          logical, pointer  :: bounded(:)

# if defined SOLVE3D && defined FLOAT_STICKY
          logical, pointer  :: stuck(:)
# endif

          integer, pointer :: Findex(:)
          integer, pointer :: Ftype(:)

          real(r8), pointer :: Flon(:)
          real(r8), pointer :: Flat(:)
          real(r8), pointer :: Fz0(:)
          real(r8), pointer :: Tinfo(:,:)
# if defined SOLVE3D && defined FLOAT_VWALK
          real(r8), pointer :: rwalk(:)
# endif
# ifdef FLOAT_OIL
          real(r8), pointer :: frroil0(:,:) ! DDMITRY
          real(r8), pointer :: wfroil0(:,:) ! DDMITRY
          real(r8), pointer :: szoil0(:)    ! DDMITRY
# endif
          real(r8), pointer :: track(:,:,:)

        END TYPE T_DRIFTER

        TYPE (T_DRIFTER), allocatable :: DRIFTER(:)
!
!-----------------------------------------------------------------------
!  Lagrangian drifters parameters.
!-----------------------------------------------------------------------
!
!  Switch to control the printing of floats positions to standard output
!  file.
!
        logical, allocatable :: Fprint(:)
!
!  Identification indices.
!
        integer, parameter :: itstr = 0          ! release time
        integer, parameter :: ixgrd = 1          ! x-grid location
        integer, parameter :: iygrd = 2          ! y-grid location
        integer, parameter :: izgrd = 3          ! z-grid location
        integer, parameter :: iflon = 4          ! longitude location
        integer, parameter :: iflat = 5          ! latitude location
        integer, parameter :: idpth = 6          ! depth
        integer, parameter :: ixrhs = 7          ! x-slope
        integer, parameter :: iyrhs = 8          ! y-slope
        integer, parameter :: izrhs = 9          ! z-slope
        integer, parameter :: ifden = 10         ! density anomaly
!MMMM Changes added by Xu Chen

#ifndef OFFLINE_FLOATS
#  ifdef FLOAT_VWALK
        integer, parameter :: ifakt = 11         ! diffusivity, Akt
        integer, parameter :: ifdak = 12         ! d(Akt)/d(s)
#  endif
#  ifdef FLOAT_OIL
#    ifdef FLOAT_VWALK
        integer, parameter :: i1oHz = 13         ! 1/Hz
        integer, parameter :: iroil = 14         ! oil density
        integer, parameter :: iwoil = 15         ! oil w-velocity
        integer, parameter :: isizo = 16         ! oil particle size
        integer, parameter :: isats = 17         ! oil saturates component fraction 
        integer, parameter :: iarom = 18         ! oil aromatics component fraction 
        integer, parameter :: isrfo = 19         ! oil surface time, sec
        integer, parameter :: ixwnd = 20         ! surf wind at oil location, x-slope
        integer, parameter :: iywnd = 21         ! surf wind at oil location, y-slope
#    else
        integer, parameter :: i1oHz = 11         ! 1/Hz
        integer, parameter :: iroil = 12         ! oil density
        integer, parameter :: iwoil = 13         ! oil w-velocity
        integer, parameter :: isizo = 14         ! oil particle size
        integer, parameter :: isats = 15         ! oil saturates component fraction 
        integer, parameter :: iarom = 16         ! oil aromatics component fraction 
        integer, parameter :: isrfo = 17         ! oil surface time, sec
        integer, parameter :: ixwnd = 18         ! surf wind at oil location, u comp
        integer, parameter :: iywnd = 19         ! surf wind at oil location, v comp
#    endif
#  endif
#endif

# ifdef OFFLINE_FLOATS
        integer, parameter :: ixspc = 11         ! x-space location
        integer, parameter :: iyspc = 12         ! y-space location
        integer, parameter :: iwdph = 13         ! water depth
        integer, parameter :: ifHzz = 14         ! Hz
#  ifdef FLOAT_VWALK
        integer, parameter :: ifakt = 15         ! diffusivity, Akt
        integer, parameter :: ifdak = 16         ! d(Akt)/d(s)
#  endif
#  ifdef FLOAT_OIL
#    ifdef FLOAT_VWALK
        integer, parameter :: i1oHz = 17         ! 1/Hz
        integer, parameter :: iroil = 18         ! oil density
        integer, parameter :: iwoil = 19         ! oil w-velocity
        integer, parameter :: isizo = 20         ! oil particle size
        integer, parameter :: isats = 21         ! oil saturates component fraction 
        integer, parameter :: iarom = 22         ! oil aromatics component fraction 
        integer, parameter :: isrfo = 23         ! oil surface time, sec
        integer, parameter :: ixwnd = 24         ! surf wind at oil location, x-slope
        integer, parameter :: iywnd = 25         ! surf wind at oil location, y-slope
#    else
        integer, parameter :: i1oHz = 15         ! 1/Hz
        integer, parameter :: iroil = 16         ! oil density
        integer, parameter :: iwoil = 17         ! oil w-velocity
        integer, parameter :: isizo = 18         ! oil particle size
        integer, parameter :: isats = 19         ! oil saturates component fraction 
        integer, parameter :: iarom = 20         ! oil aromatics component fraction 
        integer, parameter :: isrfo = 21         ! oil surface time, sec
        integer, parameter :: ixwnd = 22         ! surf wind at oil location, u comp
        integer, parameter :: iywnd = 23         ! surf wind at oil location, v comp
#    endif
#  endif

# endif


!WWWW Changes added by Xu Chen

!MMMM comment by Xu Chen
!# ifdef FLOAT_VWALK
!        integer, parameter :: ifakt = 11         ! diffusivity, Akt
!        integer, parameter :: ifdak = 12         ! d(Akt)/d(s)
!# endif
!# ifdef OFFLINE_FLOATS
!        integer, parameter :: ixspc = 11         ! x-space location
!        integer, parameter :: iyspc = 12         ! y-space location
!        integer, parameter :: iwdph = 13         ! water depth
!        integer, parameter :: ifHzz = 14         ! Hz
!#  ifdef FLOAT_VWALK
!        integer, parameter :: ifakt = 15         ! diffusivity, Akt
!        integer, parameter :: ifdak = 16         ! d(Akt)/d(s)
!#  endif
!# endif
!WWWW Comment by Xu Chen

!MMMM comment by Xu Chen
! DDMITRY - ADD OIL FLOAT parameters - also need to change mod_param.F NFV
!# ifdef FLOAT_OIL
!#  ifdef FLOAT_VWALK
!        integer, parameter :: i1oHz = 13         ! 1/Hz
!        integer, parameter :: iroil = 14         ! oil density
!        integer, parameter :: iwoil = 15         ! oil w-velocity
!        integer, parameter :: isizo = 16         ! oil particle size
!        integer, parameter :: isats = 17         ! oil saturates component fraction 
!        integer, parameter :: iarom = 18         ! oil aromatics component fraction 
!        integer, parameter :: isrfo = 19         ! oil surface time, sec
!        integer, parameter :: ixwnd = 20         ! surf wind at oil location, x-slope
!        integer, parameter :: iywnd = 21         ! surf wind at oil location, y-slope
!#  else
!        integer, parameter :: i1oHz = 11         ! 1/Hz
!        integer, parameter :: iroil = 12         ! oil density
!        integer, parameter :: iwoil = 13         ! oil w-velocity
!        integer, parameter :: isizo = 14         ! oil particle size
!        integer, parameter :: isats = 15         ! oil saturates component fraction 
!        integer, parameter :: iarom = 16         ! oil aromatics component fraction 
!        integer, parameter :: isrfo = 17         ! oil surface time, sec
!        integer, parameter :: ixwnd = 18         ! surf wind at oil location, u comp
!        integer, parameter :: iywnd = 19         ! surf wind at oil location, v comp
!#  endif
!# endif
! DD END
!WWWW Comment by Xu Chen
# ifdef FLOAT_OYSTER
#  ifdef FLOAT_VWALK
        integer, parameter :: i1oHz = 13         ! 1/Hz
        integer, parameter :: isizf = 14         ! larvae size (length)
        integer, parameter :: ibrhs = 15         ! behavior RHS
        integer, parameter :: iswim = 16         ! swimming time
        integer, parameter :: iwbio = 17         ! biological w-velocity
        integer, parameter :: iwsin = 18         ! sinking velocity
#  else
        integer, parameter :: i1oHz = 11         ! 1/Hz
        integer, parameter :: isizf = 12         ! larvae size (length)
        integer, parameter :: ibrhs = 13         ! behavior RHS
        integer, parameter :: iswim = 14         ! swimming time
        integer, parameter :: iwbio = 15         ! biological w-velocity
        integer, parameter :: iwsin = 16         ! sinking velocity
#  endif
# endif
# ifdef SOLVE3D
!
!  Tracer variables indices in the track array.
!
        integer, allocatable :: ifTvar(:)
# endif
!
!  Set float tracjectory types:
!
!    flt_Lagran:  3D Lagrangian floats
!    flt_Isobar:  Isobaric floats, p=g*(z+zeta)=constant
!    flt_Geopot:  Geopotential floats, constant depth
!
        integer, parameter :: flt_Lagran = 1
        integer, parameter :: flt_Isobar = 2
        integer, parameter :: flt_Geopot = 3

# ifdef FLOAT_VWALK
!
!  Vertical random walk, initial seed state.
!
        integer :: flt_iseed
# endif
!
! DDMITRY
# ifdef FLOAT_OIL
! Variables and parameters that
! will be read from oil*.in
! DoilMn - mean oil size, microm, parameter in Gamma distrib
!          needed for generating oil sizes
! Nocmp - # of oil components
! RhoOilComp - densities of oil components
! FlxVoilDay - constant Vol Oil flux from the spill, m3/day
! VoilFlt - vol of oil in 1 float m3
! CWndOil - oil-wind drag coefficient, =0 - no wind effect
! DfsOil  - eddy coefficient approximating diffusivity, m2/s
! see read_fltpar.F
!
        integer :: Nocmp
        real (r8) :: DoilMn, FlxVoilDay, VoilFlt
        real(r8) :: CWndOil, DfsOil
        real(r8), allocatable ::  RhoOilComp(:) 
# endif
! END DD
!
!  Floats restart switch.
!
        integer, allocatable :: frrec(:)
!
      CONTAINS
!
      SUBROUTINE allocate_floats (Ldrifter)
!
!=======================================================================
!                                                                      !
!  This routine eihter  allocates and initialize all variables in      !
!  the DRIFTER structure (Ldrifter=.TRUE.) or other parameters in      !
!  the module that are independent of Nfloats (Ldrifter=.FALSE.).      !
!                                                                      !
!=======================================================================
!
      USE mod_scalars
!
!  Imported variable declarations.
!
      logical, intent(in) :: Ldrifter
!
!  Local variable declarations.
!
      integer :: ng, i, ic, iflt

      real(r8), parameter :: IniVal = 0.0_r8
!
!-----------------------------------------------------------------------
!  Allocate Langrangian drifters structure.
!-----------------------------------------------------------------------
!
      IF (Ldrifter) THEN

        allocate ( DRIFTER(Ngrids) )
!
!  Allocate variables.
!
        DO ng=1,Ngrids
          allocate ( DRIFTER(ng) % bounded(Nfloats(ng)) )

# if defined SOLVE3D && defined FLOAT_STICKY
          allocate ( DRIFTER(ng) % stuck(Nfloats(ng)) )
# endif

          allocate ( DRIFTER(ng) % Findex(0:Nfloats(ng)) )

          allocate ( DRIFTER(ng) % Ftype(Nfloats(ng)) )

          allocate ( DRIFTER(ng) % Flon(Nfloats(ng)) )

          allocate ( DRIFTER(ng) % Flat(Nfloats(ng)) )

          allocate ( DRIFTER(ng) % Fz0(Nfloats(ng)) )

          allocate ( DRIFTER(ng) % Tinfo(0:izrhs,Nfloats(ng)) )

# if defined SOLVE3D && defined FLOAT_VWALK
          allocate ( DRIFTER(ng) % rwalk(Nfloats(ng)) )
# endif
# ifdef FLOAT_OIL
          allocate ( DRIFTER(ng) % frroil0(Nfloats(ng),Nocmp) ) ! DDMITRY
          allocate ( DRIFTER(ng) % wfroil0(Nfloats(ng),Nocmp) ) ! DDMITRY
          allocate ( DRIFTER(ng) % szoil0(Nfloats(ng)) )        ! DDMITRY
# endif

          allocate ( DRIFTER(ng) % track(NFV(ng),0:NFT,Nfloats(ng)) )
        END DO
      END IF
!
!-----------------------------------------------------------------------
!  Lagrangian drifters parameters.
!-----------------------------------------------------------------------
!
      IF (.not.Ldrifter) THEN
        allocate ( Fprint(Ngrids) )
        allocate ( frrec(Ngrids) )

# ifdef SOLVE3D
        allocate ( ifTvar(MT) )
# endif
      END IF
!
!-----------------------------------------------------------------------
!  Initialize Langrangian drifters structure.
!-----------------------------------------------------------------------
!
      IF (Ldrifter) THEN
        DO ng=1,Ngrids
          DRIFTER(ng) % Findex(0) = 0
          DO iflt=1,Nfloats(ng)
            DRIFTER(ng) % bounded(iflt) = .FALSE.
# if defined SOLVE3D && defined FLOAT_STICKY
            DRIFTER(ng) % stuck(iflt) = .FALSE.
# endif
            DRIFTER(ng) % Findex(iflt) = 0
            DRIFTER(ng) % Ftype(iflt) = 0
            DRIFTER(ng) % Flon(iflt) = IniVal
            DRIFTER(ng) % Flat(iflt) = IniVal
            DRIFTER(ng) % Fz0(iflt) = 0
# if defined SOLVE3D && defined FLOAT_VWALK
            DRIFTER(ng) % rwalk = IniVal
# endif
# ifdef FLOAT_OIL
! DDMITRY
!            IF (iflt==4116) THEN
!              print*,'INITIALIZING: Float =',iflt,' frroil, wfroil'
!            ENDIF
 
            DO i=1,Nocmp
              DRIFTER(ng) % frroil0(iflt,i) = 0.0_r8 
              DRIFTER(ng) % wfroil0(iflt,i) = 0.0_r8
            ENDDO
            DRIFTER(ng) % szoil0(iflt) = 0.0_r8 
! END DD
# endif
            DO i=0,izrhs
              DRIFTER(ng) % Tinfo(i,iflt) = IniVal
            END DO
            DO i=1,NFV(ng)
              DRIFTER(ng) % track(i,0,iflt) = IniVal
              DRIFTER(ng) % track(i,1,iflt) = IniVal
              DRIFTER(ng) % track(i,2,iflt) = IniVal
              DRIFTER(ng) % track(i,3,iflt) = IniVal
              DRIFTER(ng) % track(i,4,iflt) = IniVal
            END DO
          END DO
        END DO
      END IF
!
!-----------------------------------------------------------------------
!  Initialize Langrangian drifters parameters.
!-----------------------------------------------------------------------
!
      IF (.not.Ldrifter) THEN
# ifdef FLOAT_VWALK
        flt_iseed=149876
# endif
        DO ng=1,Ngrids
          Fprint(ng)=.TRUE.
        END DO

# ifdef SOLVE3D
!
!  Indices for tracer variables in the floats array track.
!
# ifdef FLOAT_OYSTER
#  ifdef FLOAT_VWALK
        ic=18
#  else
        ic=16
#  endif
!# else
!#  ifdef FLOAT_VWALK
!        ic=12
!#  else
!        ic=10
!#  endif
!# endif
! DDMITRY
# elif defined FLOAT_OIL
#  ifdef FLOAT_VWALK
        ic=21
#  else
        ic=19
#  endif
        Nocmp = 0 ! # of oil compnents initial value, set in oil*.in
        DoilMn = -999.0 ! mean oil size, set in oil*.in
        FlxVoilDay = -999.0 ! oil flux rate, m3/day
        VoilFlt = -999.0    ! oil volume in 1 float
        DfsOil = -999.0 ! oil diffusiv., used in rand walk approxim. 
        CWndOil = -999.0 ! wind-oil coefficient
# else
#  ifdef FLOAT_VWALK
        ic=12
#  else
        ic=10
#  endif
# endif
! DD END
        DO i=1,MT
          ic=ic+1
          ifTvar(i)=ic
        END DO
#endif
      END IF

      RETURN
      END SUBROUTINE allocate_floats
#endif
      END MODULE mod_floats
