#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="distributed"
pkg_name="mvapich2-runtime"

pkg_default="1.9a"
pkg_variants=("1.8.1" "1.9a")

pkg_info="MVAPICH2 aka MPI-2 over OpenFabrics-IB, OpenFabrics-iWARP, PSM, uDAPL and TCP/IP."

pkg_desc="MVAPICH2 aka MPI-2 over OpenFabrics-IB, OpenFabrics-iWARP, PSM, uDAPL and TCP/IP

This is an MPI-2 implementation (conforming to MPI 2.2 standard) which includes all 
MPI-1 features. It is based on MPICH2 and MVICH. The latest release is MVAPICH2 1.8 
(includes MPICH2 1.4.1p1). It is available under BSD licensing."

pkg_opts="configure force-serial-build enable-shared skip-auto-compile-flags skip-system-flags"
pkg_reqs="zlib libtool papi gfortran valgrind hwloc"
pkg_uses="$pkg_reqs"

pkg_cflags=""
pkg_ldflags=""

pkg_cfg=""
if [ -d "/usr/local/cuda" ]
then
     pkg_cfg+="--enable-cuda "
     pkg_cfg+="--with-cuda=/usr/local/cuda "
     pkg_cfg+="--with-cuda-include=/usr/local/cuda/include "
     pkg_cfg+="--with-cuda-libpath=/usr/local/cuda/lib64 "
fi

# pkg_cfg+="--enable-threads=runtime "
# pkg_cfg+="--with-thread-package=posix "
pkg_cfg+="--enable-romio "
pkg_cfg+="--enable-cxx "
pkg_cfg+="--enable-fc "
pkg_cfg+="--enable-error-checking=runtime "
pkg_cfg+="--enable-timing=none "
pkg_cfg+="--enable-g=mem,dbg,meminit "
pkg_cfg+="--enable-mpe "
pkg_cfg+="--enable-sharedlibs=gcc "
pkg_cfg+="--with-rdma=gen2 "

# pkg_cfg+="--enable-ckpt"
# pkg_cfg+="--enable-ckpt-aggregation"
# pkg_cfg+="--enable-ckpt-migration"

#
# Disable vampire trace avoids build errors on OSX:
#
# - Building MVAPICH2 > v1.5.4 on OSX causes error due to missing GCC internal
#   '__builtin_expect' directives when compiling with LLVM-GCC
#
if [[ $BLDR_SYSTEM_IS_OSX == true ]] 
then
    pkg_cfg+="--disable-vt "
fi

if [[ $BLDR_SYSTEM_IS_LINUX == true ]] 
then
     pkg_cflags+="-fPIC "    
fi

####################################################################################################
# register each pkg version with bldr
####################################################################################################

if [[ $BLDR_SYSTEM_IS_OSX == true ]]
then
     bldr_log_status "$pkg_name $pkg_vers is not building on OSX right now.  Skipping ..."
     bldr_log_split
else

     for pkg_vers in ${pkg_variants[@]}
     do
          pkg_file="mvapich2-$pkg_vers.tgz"
          pkg_urls="http://mvapich.cse.ohio-state.edu/download/mvapich2/$pkg_file"

          bldr_register_pkg                \
              --category    "$pkg_ctry"    \
              --name        "$pkg_name"    \
              --version     "$pkg_vers"    \
              --default     "$pkg_default" \
              --info        "$pkg_info"    \
              --description "$pkg_desc"    \
              --file        "$pkg_file"    \
              --url         "$pkg_urls"    \
              --uses        "$pkg_uses"    \
              --requires    "$pkg_reqs"    \
              --options     "$pkg_opts"    \
              --cflags      "$pkg_cflags"  \
              --ldflags     "$pkg_ldflags" \
              --config      "$pkg_cfg"     \
              --config-path "$pkg_cfg_path"
     done
fi

####################################################################################################


