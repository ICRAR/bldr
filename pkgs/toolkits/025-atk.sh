#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="toolkits"
pkg_name="atk"
pkg_vers="2.4.0"

pkg_info="The Accessibility ToolKit (ATK) provides the set of accessibility interfaces that are implemented by other toolkits and applications."

pkg_desc="The Accessibility ToolKit (ATK) provides the set of accessibility interfaces 
that are implemented by other toolkits and applications. Using the ATK interfaces, 
accessibility tools have full access to view and control running applications."

pkg_file="$pkg_name-$pkg_vers.tar.xz"
pkg_urls="http://ftp.gnome.org/pub/gnome/sources/atk/2.4/$pkg_file"
pkg_opts="configure"
pkg_reqs="$pkg_reqs zlib/latest"
pkg_reqs="$pkg_reqs libxml2/latest"
pkg_reqs="$pkg_reqs libicu/latest"
pkg_reqs="$pkg_reqs libiconv/latest"
pkg_reqs="$pkg_reqs gtk-doc/latest"
pkg_reqs="$pkg_reqs glib/latest"
pkg_reqs="$pkg_reqs gobject-isl/latest"
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

pkg_cfg=""
pkg_cfg_path=""
pkg_cflags=""
pkg_ldflags=""

####################################################################################################
# build and install pkg as local module
####################################################################################################

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
               --config      "$pkg_cfg"     \
               --config-path "$pkg_cfg_path"

