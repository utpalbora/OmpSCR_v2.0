########################################
#
# OpenMP Source Code Repository
#
# COMPILER CONFIGURATION MAKEFILE
#
# This file include details about your C, C++ and/or Fortran90/95 compilers
# and compilation flags, common to all applications
#
########################################


########################################
#
# SECTION 1: C COMPILER
#
TOOL=romp

ROMP_ROOT=/home/utpal/RaceDetectionTools/ROMP/romp
#CPATH=$(ROMP_ROOT)/pkgs-src/llvm-openmp/openmp/llvm-openmp-install/include:$(CPATH)
#LD_LIBRARY_PATH=$(ROMP_ROOT)/pkgs-src/llvm-openmp/openmp/llvm-openmp-install/lib:$(LD_LIBRARY_PATH)
#LD_LIBRARY_PATH=$(ROMP_ROOT)/pkgs-src/gperftools/gperftools-install/lib:$(LD_LIBRARY_PATH)
#LD_LIBRARY_PATH=$(ROMP_ROOT)/pkgs-src/dyninst/dyninst-install/lib:$(LD_LIBRARY_PATH)
#DYNINST_ROOT=$(ROMP_ROOT)/pkgs-src/dyninst/dyninst-install
ROMP_LIB=$(ROMP_ROOT)/pkgs-src/romp-lib/romp-install/lib
OMP_LIB=$(ROMP_ROOT)/pkgs-src/llvm-openmp/openmp/llvm-openmp-install/lib
GPERFTOOLS_LIB=$(ROMP_ROOT)/pkgs-src/gperftools/gperftools-install/lib
ROMP_PATH=$(ROMP_LIB)/libomptrace.so
export ROMP_PATH
#DYNINST_CLIENT=$(ROMP_ROOT)/pkgs-src/dyninst-client/omp_race_client
#DYNINSTAPI_RT_LIB=$(DYNINST_ROOT)/lib/libdyninstAPI_RT.so

#
# 1.1. C compiler activation
#	A value of "y" will enable C source code compilation
#	A value of "n" will unable C source code compilation
#
OSCR_USE_C=y

#
# 1.2. The name of your C compiler or front-end
#
OSCR_CC=clang-8

#
# 1.3. Flag/s needed to activate OpenMP pragmas recognition
#
OSCR_C_OMPFLAG=-fopenmp

#
# 1.4. Flag/s needed for serial compilation (No OpenMP)
#
OSCR_C_OMPSTUBSFLAG=

#
# 1.5. (Optional)
#	Flags to obtain some report or information about the parallelization
#
OSCR_C_REPORT=

#
# 1.6. (Optional) Other common flags (e.g. optimization)
#
OSCR_C_OTHERS=-g -O0 -L$(ROMP_LIB) -L$(GPERFTOOLS_LIB) -L$(OMP_LIB) -fpermissive -ltcmalloc



########################################
#
# SECTION 2: C++ COMPILER
#

#
# 2.1. C++ compiler activation
#	A value of "y" will enable C++ source code compilation
#	A value of "n" will unable C++ source code compilation
#
OSCR_USE_CPP=y

#
# 2.2. The name of your C++ compiler or front-end
#
OSCR_CPPC=clang++-8

#
# 2.3. Flag/s needed to activate OpenMP pragmas recognition
#
OSCR_CPP_OMPFLAG=-fopenmp

#
# 2.4. Flag/s needed for serial compilation (No OpenMP)
#
OSCR_CPP_OMPSTUBSFLAG=

#
# 2.5. (Optional)
#	Flags to obtain some report or information about the parallelization
#
OSCR_CPP_REPORT=

#
# 2.6. (Optional) Other common flags (e.g. optimization)
#
OSCR_CPP_OTHERS=-g -O0 -L$(ROMP_LIB) -L$(GPERFTOOLS_LIB) -L$(OMP_LIB) -fpermissive -ltcmalloc


########################################
#
# SECTION 3: Fortran90/95 COMPILER
#

#
# 3.1. Frotran90/95 compiler activation
#	A value of "y" will enable Fortran90/95 source code compilation
#	A value of "n" will unable Fortran90/95 source code compilation
#
OSCR_USE_F=n

#
# 3.2. The name of your Frotran90/95 compiler or front-end
#
OSCR_FF=

#
# 3.3. Flag/s needed to activate OpenMP pragmas recognition
#
OSCR_F_OMPFLAG=

#
# 3.4. Flag/s needed for serial compilation (No OpenMP)
#
OSCR_F_OMPSTUBSFLAG=

#
# 3.5. (Optional)
#	Flags to obtain some report or information about the parallelization
#
OSCR_F_REPORT=

#
# 3.6. (Optional) Other common flags (e.g. optimization)
#
OSCR_F_OTHERS=



#
# END OF COMPILER CONFIGURATION MAKEFILE
#
########################################
