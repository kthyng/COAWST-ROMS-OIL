[![DOI](https://zenodo.org/badge/250098905.svg)](https://zenodo.org/badge/latestdoi/250098905)

# ROMS-OIL
Oil plume model coupled with ROMS

Oil plume model utilizes Lagrangian float option in ROMS with added vertical velocity determined from the oil droplet sizes, oil component wegith fraction, density. At the surface, oil droplets are subject to weathering (evaporation) and wind drift (optional). Oil droplet size is assigned by generating random number from Gamma distribution. Two alogirhtms calculating vertical velocity of oil droplets are available and defined by users (two-equation or integrated). 

The oil module resides in the directory ROMS/Nonlinear/Oil. However, there are multiple changes throughout the ROMS code to incroporate the oil module, oil array passing, and I/O. Several new script files have been added in the ROMS directories. Thus it is recommended to copy whole ROMS directory into COAWST. 

To compile Oil module, one needs to add directories with the oil module and includes/headers in makefile script:
ifdef USE_ROMS
 includes +=	ROMS/Nonlinear \
		ROMS/Nonlinear/Biology \
		ROMS/Nonlinear/Oil \
		ROMS/Nonlinear/Sediment \
...


ifdef USE_ROMS
 modules  +=	ROMS/Nonlinear \
		ROMS/Nonlinear/Biology \
		ROMS/Nonlinear/Oil \
...

Note the floats include file has been modified to add input information for the oil model:
e.g., more <expt>_floats.in

NFLOATS == 16000\
Lfloats == T\
Fprint == T\
FRREC == 0\
Nocmp == 3\
OilComp == saturates aromatics res_asph\
OilDens == 800.0 860.0 1030.0\
DoilMn == 500.0e-6\
FlxVoilDay == 3000.0\
CWndOil == 0.02\
DfsOil == 15.0\

POS = G, C, T,    N,     Ft0,    Fx0,      Fy0,     Fz0,    Fdt,   Fdx,   Fdy,   Fdz\

      1  1  1  2000    0.d0   -88.367d0 28.737d0 -1400.d0 0.01d0 0.d0   0.d0  0.d0
      1  1  1  2000    0.d0   -88.369d0 28.739d0 -1400.d0 0.01d0 0.d0   0.d0  0.d0
      1  1  1  2000    0.d0   -88.372d0 28.742d0 -1400.d0 0.01d0 0.d0   0.d0  0.d0
      1  1  1  2000    0.d0   -88.369d0 28.735d0 -1400.d0 0.01d0 0.d0   0.d0  0.d0
      1  1  1  2000    0.d0   -88.372d0 28.732d0 -1400.d0 0.01d0 0.d0   0.d0  0.d0
      1  1  1  2000    0.d0   -88.364d0 28.734d0 -1400.d0 0.01d0 0.d0   0.d0  0.d0
      1  1  1  2000    0.d0   -88.361d0 28.731d0 -1400.d0 0.01d0 0.d0   0.d0  0.d0
      1  1  1  2000    0.d0   -88.365d0 28.738d0 -1400.d0 0.01d0 0.d0   0.d0  0.d0


Change definitions in the <expt>.h
To turn the oil model on with Lagrangian -> Euler mapping of the oil fields
two-equaltion algorithm for the oil plume is implemented

#define FLOATS\
#define FLOAT_OIL\
#define FLOAT_VWALK\
#undef WOIL_INTEGRATED\
#undef OIL_DEBUG\
#define OIL_EULR\
  
wind drift is automaticly "on" when bulk fluxes are defined unless CWndOil =0 in the <expt>_floats.in

#define  BULK_FLUXES\
  
To turn off the oil model and ROMS as a stand-alone model:

#undef FLOATS\
#undef FLOAT_OIL\
#undef FLOAT_VWALK\
#undef WOIL_INTEGRATED\
#undef OIL_DEBUG\
#undef OIL_EULR\

Do not turn OIL_DEBUG on, this will produce large log file. OIL_EULR can be turned off if mapping is not needed. 

Note the code is still under development. The uploaded version is working but not final. Report any bugs to ddukhovskoy@fsu.edu. 


