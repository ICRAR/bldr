#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="numerics"
pkg_name="gmp"

pkg_default="6.1.2"
pkg_variants=("5.1.3" "6.1.2")

pkg_info="GMP is a free library for arbitrary precision arithmetic, operating on signed integers, rational numbers, and floating point numbers."

pkg_desc="GMP is a free library for arbitrary precision arithmetic, operating on 
signed integers, rational numbers, and floating point numbers. There is no 
practical limit to the precision except the ones implied by the available memory 
in the machine GMP runs on. GMP has a rich set of functions, and the functions 
have a regular interface.

The main target applications for GMP are cryptography applications and research, 
Internet security applications, algebra systems, computational algebra research, etc.

GMP is carefully designed to be as fast as possible, both for small operands
and for huge operands. The speed is achieved by using fullwords as the basic 
arithmetic type, by using fast algorithms, with highly optimised assembly code 
for the most common inner loops for a lot of CPUs, and by a general emphasis on speed.

GMP is faster than any other bignum library. The advantage for GMP increases with 
the operand sizes for many operations, since GMP uses asymptotically faster algorithms.

The first GMP release was made in 1991. It is continually developed and maintained, 
with a new release about once a year."

pkg_opts="configure enable-static enable-shared"
#pkg_reqs="pkg-config zlib"
pkg_reqs="zlib"
pkg_uses="$pkg_reqs"
pkg_cfg="--enable-cxx"
pkg_patch=""
pkg_cflags=""
pkg_ldflags=""

####################################################################################################
# build and install pkg as local module
####################################################################################################

for pkg_vers in ${pkg_variants[@]}
do
     pkg_file="$pkg_name-$pkg_vers.tar.bz2"
     pkg_urls="ftp://ftp.gmplib.org/pub/$pkg_name-$pkg_vers/$pkg_file"

     bldr_register_pkg                 \
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

