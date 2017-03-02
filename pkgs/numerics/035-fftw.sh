#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="numerics"
pkg_name="fftw"

pkg_default="3.3.6"
pkg_variants=("3.3.6")

pkg_info="FFTW is a C subroutine library for computing the discrete Fourier transform (DFT) in one or more dimensions, of arbitrary input size, and of both real and complex data."

pkg_desc="FFTW is a C subroutine library for computing the discrete Fourier transform (DFT) 
in one or more dimensions, of arbitrary input size, and of both real and complex data 
(as well as of even/odd data, i.e. the discrete cosine/sine transforms or DCT/DST). 
We believe that FFTW, which is free software, should become the FFT library of choice 
for most applications."

pkg_opts="configure enable-static enable-shared"
pkg_cfg=""
pkg_cfg="--enable-threads --enable-sse2 "
if [ $BLDR_SYSTEM_IS_LINUX == true ]
then
    pkg_cfg+="--enable-openmp --enable-avx --enable-mpi "
    pkg_cflags+="-fPIC "
fi

pkg_uses="openmpi"
pkg_reqs="openmpi"

pkg_cflags=""
pkg_ldflags=""

####################################################################################################
# build and install pkg as local module
####################################################################################################

for pkg_vers in ${pkg_variants[@]}
do
    pkg_file="$pkg_name-$pkg_vers-pl1.tar.gz"
    pkg_urls="http://www.fftw.org/$pkg_file"

    bldr_register_pkg                  \
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

####################################################################################################
