#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="protocols"
pkg_name="zeromq-java"
pkg_vers="2.1.0"
pkg_vers_list=("$pkg_vers")
pkg_info="Java Bindings for ZeroMQ -- a set of components for building scalable and high performance distributed applications"

pkg_desc="Java Bindings for ZeroMQ -- a set of components for building scalable and high performance distributed applications"

pkg_file="$pkg_name-$pkg_vers.tar.gz"
pkg_urls="git://github.com/zeromq/jzmq.git"
pkg_opts="configure force-bootstrap"
pkg_reqs="pkg-config/latest libtool/latest gettext/latest autoconf/latest automake/latest m4/latest zeromq/2.1.7"
pkg_uses="$pkg_req"

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
pkg_cfg="--with-zeromq=$BLDR_ZEROMQ_BASE_PATH" 

####################################################################################################
# build and install pkg as local module
####################################################################################################

for zmq_vers in ${pkg_vers_list[@]}
do
     pkg_vers=$zmq_vers
     pkg_file="$pkg_name-$zmq_vers.tar.gz"
     pkg_urls="git://github.com/zeromq/jzmq.git"
     bldr_build_pkg --category    "$pkg_ctry"    \
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
done

