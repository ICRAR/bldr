#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_name="openmpi"
pkg_vers="1.6"

pkg_info="The Open MPI Project is an open source MPI-2 implementation that is developed and maintained by a consortium of academic, research, and industry partners."

pkg_desc="The Open MPI Project is an open source MPI-2 implementation that is developed and 
maintained by a consortium of academic, research, and industry partners. 

Open MPI is therefore able to combine the expertise, technologies, and resources from all 
across the High Performance Computing community in order to build the best MPI library available. 

Open MPI offers advantages for system and software vendors, application developers and computer 
science researchers."

pkg_file="$pkg_name-$pkg_vers.tar.bz2"
pkg_urls="http://www.open-mpi.org/software/ompi/v1.6/downloads/$pkg_file"
pkg_opts="configure"
pkg_reqs="zlib/latest papi/latest torque/latest"
pkg_uses="m4/latest autoconf/latest automake/latest $pkg_reqs"
pkg_cflags="-I$BLDR_LOCAL_DIR/system/zlib/latest/include"
pkg_ldflags="-L$BLDR_LOCAL_DIR/system/zlib/latest/lib"
pkg_cfg="--enable-btl-openib-failover --enable-heterogeneous --enable-mpi-thread-multiple"

if [ -d $BLDR_LOCAL_DIR/cluster/torque/latest ]
then 
     pkg_cfg="$pkg_cfg --with-tm=\"$BLDR_LOCAL_DIR/cluster/torque/latest\""
fi

if [ "$BLDR_SYSTEM_IS_OSX" -eq 1 ]
then
     # Building v1.5.4 on OSX causes error due to missing '__builtin_expect' -- disable vampire trace avoids this
    pkg_cfg="$pkg_cfg --disable-vt "
fi

####################################################################################################
# build and install pkg as local module
####################################################################################################

bldr_build_pkg --category    "cluster"      \
               --name        "$pkg_name"    \
               --version     "$pkg_vers"    \
               --info        "$pkg_info"    \
               --description "$pkg_desc"    \
               --file        "$pkg_file"    \
               --url         "$pkg_urls"    \
               --uses        "$pkg_uses"    \
               --requires    "$pkg_reqs"    \
               --options     "$pkg_opts"    \
               --cflags      "$pkg_cflags"  \
               --ldflags     "$pkg_ldflags" \
               --config      "$pkg_cfg"

