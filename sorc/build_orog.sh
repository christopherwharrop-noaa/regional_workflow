#!/bin/sh
#####################################################################################
# orog using module compile standard
# 10/10/2016 Fanglin.Yang@noaa.gov:    Create module load version
#####################################################################################
set -eux

source ./machine-setup.sh $1 > /dev/null 2>&1
cwd=`pwd`

USE_PREINST_LIBS=${USE_PREINST_LIBS:-"true"}
if [ $USE_PREINST_LIBS = true ]; then
  if [ $target = odin ]; then
    export MOD_PATH=/scratch/ywang/external/modulefiles
  else
    export MOD_PATH=/scratch3/NCEPDEV/nwprod/lib/modulefiles
  fi
  source ../modulefiles/fv3gfs/orog.$target
else
  export MOD_PATH=${cwd}/lib/modulefiles
  if [ $target = wcoss_cray ]; then
    source ../modulefiles/fv3gfs/orog.${target}_userlib
  else
    source ../modulefiles/fv3gfs/orog.$target
  fi
fi

# Check final exec folder exists
if [ ! -d "../exec" ]; then
  mkdir ../exec
fi

cd ./orog.fd

if [ $target = wcoss_cray ]; then
  export INCS=""
  export LIBSM="${BACIO_LIB4} ${IP_LIBd} ${W3NCO_LIBd} ${SP_LIBd}"
  export FFLAGSM="-O3 -g -traceback -r8  -convert big_endian -fp-model precise  -assume byterecl"
elif [ $target = wcoss ]; then
  export INCS="${NETCDF_INCLUDE}"
  export LIBSM="${BACIO_LIB4} ${W3NCO_LIBd} ${IP_LIBd} ${SP_LIBd} ${NETCDF_LDFLAGS}"
  export FFLAGSM="-O3 -g -traceback -r8  -convert big_endian -fp-model precise  -assume byterecl ${INCS}"
elif [ $target = theia ]; then
  export INCS="-I${NETCDF}/include"
  export LIBSM="${BACIO_LIB4} ${W3NCO_LIBd} ${IP_LIBd} ${SP_LIBd} -L${NETCDF}/lib -lnetcdff -lnetcdf"
  export FFLAGSM="-O3 -g -traceback -r8  -convert big_endian -fp-model precise  -assume byterecl ${INCS}"
elif [ $target = odin ]; then
  export INCS=""
  export LIBSM="${BACIO_LIB4} ${IP_LIBd} ${W3NCO_LIBd} ${SP_LIBd}"
  export FFLAGSM="-O3 -g -traceback -r8  -convert big_endian -fp-model precise  -assume byterecl"
elif [ $target = cheyenne ]; then
  export INCS="-I${NETCDF}/include -I${NCEPLIB_DIR}/include"
  export LIBSM="-L${NCEPLIB_DIR}/lib -lbacio_4 -lw3emc_d -lw3nco_d -lip_d -lsp_v2.0.2_d -L${NETCDF}/lib -lnetcdff -lnetcdf"
  export FFLAGSM="-O3 -g -traceback -r8  -convert big_endian -fp-model precise  -assume byterecl ${INCS}"
fi

export FCMP=${FCMP:-ifort}
export FCMP95=$FCMP

export LDFLAGSM="-qopenmp -auto"
export OMPFLAGM="-qopenmp -auto"

make -f Makefile clobber
make -f Makefile
make -f Makefile install
make -f Makefile clobber

exit
