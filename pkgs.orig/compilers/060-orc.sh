#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="compilers"
pkg_name="orc"

pkg_default="0.4.16"
pkg_variants=("0.4.16")

pkg_info="Orc is a just-in-time compiler implemented as a library and set of associated tools for compiling and executing simple programs that operate on arrays of data."

pkg_desc="Orc is a just-in-time compiler implemented as a library and set of 
associated tools for compiling and executing simple programs that operate on 
arrays of data.  Orc is unlike other general-purpose JIT engines: the Orc 
bytecode and language is designed so that it can be readily converted into 
SIMD instructions.  This translates to interesting language features and 
limitations: Orc has built-in capability for SIMD-friendly operations such 
as shuffling, saturated addition and subtraction, but only works on arrays 
of data.  This makes Orc good for applications such as image processing, 
audio processing, array math, and signal analysis."

pkg_opts="configure enable-static enable-shared"
pkg_reqs="m4 automake autoconf tar gzip"
pkg_uses=""

pkg_cflags=""
pkg_ldflags=""
pkg_cfg="" 

####################################################################################################
# register each pkg version with bldr
####################################################################################################

for pkg_vers in ${pkg_variants[@]}
do
     pkg_file="$pkg_name-$pkg_vers.tar.gz"
     pkg_urls="http://code.entropywave.com/download/$pkg_name/$pkg_file"

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


