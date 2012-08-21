#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="developer"
pkg_name="apr-util"
pkg_vers="1.4.1"
pkg_info="APR-util provides a number of helpful abstractions on top of the Apache Portable Runtime library"

pkg_desc="The mission of the Apache Portable Runtime Project is to create and maintain software 
libraries that provide a predictable and consistent interface to underlying platform-specific 
implementations. The primary goal is to provide an API to which software developers may code and 
be assured of predictable if not identical behavior regardless of the platform on which their 
software is built, relieving them of the need to code special-case conditions to work around or 
take advantage of platform-specific deficiencies or features.

APR and its companion libraries are implemented entirely in C and provide a common programming 
interface across a wide variety of operating system platforms without sacrificing performance. "

pkg_file="$pkg_name-$pkg_vers.tar.bz2"
pkg_urls="http://apache.tradebit.com/pub/apr/$pkg_file"
pkg_opts="configure"
pkg_reqs="coreutils/latest pkg-config/latest zlib/latest apr/latest"
pkg_uses="$pkg_reqs"

####################################################################################################
# satisfy pkg dependencies and load their environment settings
####################################################################################################

bldr_satisfy_pkg --category    "$pkg_ctry"    \
                 --name        "$pkg_name"    \
                 --version     "$pkg_vers"    \
                 --requires    "$pkg_reqs"    \
                 --uses        "$pkg_uses"    \
                 --options     "$pkg_opts"

####################################################################################################

pkg_cflags=""
pkg_ldflags=""
pkg_patch=""
pkg_cfg="--enable-static --enable-shared"
pkg_cfg="$pkg_cfg --with-apr=\"$BLDR_APR_BASE_PATH\""

####################################################################################################
# build and install pkg as local module
####################################################################################################

bldr_build_pkg                    \
     --category    "$pkg_ctry"    \
     --name        "$pkg_name"    \
     --version     "$pkg_vers"    \
     --info        "$pkg_info"    \
     --description "$pkg_desc"    \
     --file        "$pkg_file"    \
     --url         "$pkg_urls"    \
     --uses        "$pkg_uses"    \
     --requires    "$pkg_reqs"    \
     --options     "$pkg_opts"    \
     --patch       "$pkg_patch"   \
     --cflags      "$pkg_cflags"  \
     --ldflags     "$pkg_ldflags" \
     --config      "$pkg_cfg"

