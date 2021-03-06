#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="typography"
pkg_name="freetype"

pkg_default="2.7.1"
pkg_variants=("2.7.1")

pkg_info="FreeType is a free, high-quality, and portable font engine."

pkg_desc="FreeType 2 is a software font engine that is designed to be small, efficient, 
highly customizable, and portable while capable of producing high-quality output 
(glyph images). It can be used in graphics libraries, display servers, font conversion 
tools, text image generation tools, and many other products as well.

Note that FreeType 2 is a font service and doesn't provide APIs to perform higher-level 
features like text layout or graphics processing (e.g., colored text rendering, ‘hollowing’, 
etc.). However, it greatly simplifies these tasks by providing a simple, easy to use, 
and uniform interface to access the content of font files."

pkg_opts="configure "
pkg_opts+="force-serial-build "
pkg_reqs="zlib "
pkg_reqs+="libicu "
pkg_reqs+="libiconv "
pkg_reqs+="libxml2 "
pkg_reqs+="libpng/1.2.57 "

pkg_cflags=""
pkg_ldflags=""

pkg_cfg=""
pkg_patch=""

if [[ $BLDR_SYSTEM_IS_OSX == true ]]
then
     if [[ $BLDR_SYSTEM_IS_64BIT == true ]]
     then
          pkg_cfg+="--with-arch=x86_64"
     fi
     pkg_cfg+="--with-sysroot=$BLDR_OSX_SYSROOT"
fi

pkg_uses=$pkg_reqs

####################################################################################################
# register each pkg version with bldr
####################################################################################################

for pkg_vers in ${pkg_variants[@]}
do
    pkg_file="$pkg_name-$pkg_vers.tar.gz"
    pkg_urls="http://download.savannah.gnu.org/releases/freetype/$pkg_file"
    pkg_urls+=";http://downloads.sourceforge.net/project/$pkg_name/freetype2/$pkg_vers/$pkg_file?use_mirror=aarnet"

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
