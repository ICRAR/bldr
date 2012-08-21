#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="graphics"
pkg_name="pixman"
pkg_vers="0.26.2"

pkg_info="Pixman is a low-level software library for pixel manipulation, providing features such as image compositing and trapezoid rasterization."

pkg_desc="Pixman is a low-level software library for pixel manipulation, providing 
features such as image compositing and trapezoid rasterization. Important users of 
pixman are the cairo graphics library and the X server.

Pixman is implemented as a library in the C programming language. It runs on many 
platforms, including Linux, BSD Derivatives, MacOS X, and Windows.

Pixman is free and open source software. It is available to be redistributed and/or 
modified under the terms of the MIT license. "

pkg_file="$pkg_name-$pkg_vers.tar.gz"
pkg_urls="http://cairographics.org/releases/$pkg_file"
pkg_opts="configure"
pkg_reqs=""
pkg_reqs="$pkg_reqs zlib/latest"
pkg_reqs="$pkg_reqs libxml2/latest"
pkg_reqs="$pkg_reqs libicu/latest"
pkg_reqs="$pkg_reqs libiconv/latest"
pkg_reqs="$pkg_reqs gettext/latest"
pkg_reqs="$pkg_reqs glib/latest"
pkg_reqs="$pkg_reqs libpng/latest"
pkg_reqs="$pkg_reqs pango/latest"
pkg_uses="$pkg_reqs"

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
               --config      "$pkg_cfg"

