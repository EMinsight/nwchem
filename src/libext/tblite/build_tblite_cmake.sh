#!/usr/bin/env bash
source ../libext_utils/cmake.sh

check_tgz() {
    myexit=0
    [ -f $1 ] && gunzip -t $1 > /dev/null && myexit=1
    echo $myexit
}

VERSION=0.2.2-ilp64-alpha
TGZ=tblite-${VERSION}.tar.gz
if [ `check_tgz $TGZ` == 1 ]; then
    echo "using existing $TGZ"
else
    rm -rf tblite*
    curl -L https://github.com/dmejiar/tblite/archive/v${VERSION}.tar.gz -o $TGZ
fi

tar -xzf tblite-${VERSION}.tar.gz
ln -sf tblite-${VERSION} tblite


if [[  -z "${CC}" ]]; then
    CC=cc
fi
if [[  -z "${FC}" ]]; then
#FC not defined. Look for gfortran
    if [[ ! -x "$(command -v gfortran)" ]]; then
	echo ' '
	echo 'please define FC to compile tblite'
	echo ' '
	exit 1
    else
	echo 'FC not defined, defaulting FC=gfortran'
	FC=gfortran
    fi
fi

if [[ -z "${CMAKE}" ]]; then
    #look for cmake
    if [[ -z "$(command -v cmake)" ]]; then
	cmake_instdir=../libext_utils
	get_cmake_release $cmake_instdir
	status=$?
	if [ $status -ne 0 ]; then
	    echo cmake required to build tblite
	    echo Please install cmake
	    echo define the CMAKE env. variable
	    exit 1
	fi
    else
	CMAKE=cmake
    fi
fi
CMAKE_VER_MAJ=$(${CMAKE} --version|cut -d " " -f 3|head -1|cut -d. -f1)
CMAKE_VER_MIN=$(${CMAKE} --version|cut -d " " -f 3|head -1|cut -d. -f2)
echo CMAKE_VER is ${CMAKE_VER_MAJ} ${CMAKE_VER_MIN}
if ((CMAKE_VER_MAJ < 3)) || (((CMAKE_VER_MAJ > 2) && (CMAKE_VER_MIN < 8))); then
    get_cmake_release  $cmake_instdir
    status=$?
    if [ $status -ne 0 ]; then
	echo cmake required to build scalapack
	echo Please install cmake
	echo define the CMAKE env. variable
	exit 1
    fi
fi



if [[  -z "${BLAS_SIZE}" ]]; then
   BLAS_SIZE=8
fi
if [[ ${BLAS_SIZE} == 8 ]]; then
  ilp64=ON
else
  ilp64=OFF
fi

if [[ ! -z "$BUILD_OPENBLAS"   ]] ; then
    BLASOPT="-L`pwd`/../lib -lnwc_openblas"
fi

cd tblite
rm -rf _build

FC=$FC CC=$CC cmake -B _build -DLAPACK_LIBRARIES="$BLASOPT" -DWITH_ILP64=$ilp64 -DCMAKE_INSTALL_PREFIX="./install"
cmake --build _build --parallel 4
cmake --install _build

cd ..

touch ../lib/libnwc_tblite.a
