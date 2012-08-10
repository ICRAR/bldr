#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_name="libtiff"
pkg_vers="4.0.1"

pkg_info="The Tag Image File Format (TIFF) is a widely used format for storing image data."

pkg_desc="The Tag Image File Format (TIFF) is a widely used format for storing image data.
This software provides support for the Tag Image File Format (TIFF), a widely used format 
for storing image data. The latest version of the TIFF specification is available on-line 
in several different formats.

Included in this software distribution is a library, libtiff, for reading and writing TIFF, 
a small collection of tools for doing simple manipulations of TIFF images, and documentation 
on the library and tools. Libtiff is a portable software, it was built and tested on various 
systems: UNIX flavors (Linux, BSD, Solaris, MacOS X), Windows, and OpenVMS. It should be 
possible to port libtiff and additional tools on other OSes.

The library, along with associated tool programs, should handle most of your needs for 
reading and writing TIFF images on 32- and 64-bit machines."

pkg_file="tiff-4.0.1.tar.gz"
pkg_urls="http://download.osgeo.org/libtiff/$pkg_file"
pkg_opts="configure"
pkg_reqs="zlib/latest libpng/latest libjpeg/latest"
pkg_uses="$pkg_reqs"
pkg_cflags="-I$BLDR_LOCAL_PATH/compression/zlib/latest/include"
pkg_cflags="$pkg_cflags:-I$BLDR_LOCAL_PATH/imaging/libpng/latest/include"
pkg_cflags="$pkg_cflags:-I$BLDR_LOCAL_PATH/imaging/libjpeg/latest/include"

pkg_ldflags="-L$BLDR_LOCAL_PATH/compression/zlib/latest/lib"
pkg_ldflags="$pkg_ldflags:-L$BLDR_LOCAL_PATH/imaging/libpng/latest/lib"
pkg_ldflags="$pkg_ldflags:-L$BLDR_LOCAL_PATH/imaging/libjpeg/latest/lib"

pkg_cfg="--with-gnu-ld"
pkg_cfg="$pkg_cfg --with-jpeg-lib-dir=$BLDR_LOCAL_PATH/imaging/libjpeg/latest/lib"
pkg_cfg="$pkg_cfg --with-jpeg-include-dir=$BLDR_LOCAL_PATH/imaging/libjpeg/latest/include"
pkg_cfg="$pkg_cfg --with-zlib-lib-dir=$BLDR_LOCAL_PATH/compression/zlib/latest/lib"
pkg_cfg="$pkg_cfg --with-zlib-include-dir=$BLDR_LOCAL_PATH/compression/zlib/latest/include"

####################################################################################################

function bldr_pkg_compile_method()
{
    local use_verbose="false"
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_uses=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""
    local pkg_cfg_path=""

    while true ; do
        case "$1" in
           --verbose)       use_verbose="$2"; shift 2;;
           --name)          pkg_name="$2"; shift 2;;
           --version)       pkg_vers="$2"; shift 2;;
           --info)          pkg_info="$2"; shift 2;;
           --description)   pkg_desc="$2"; shift 2;;
           --category)      pkg_ctry="$2"; shift 2;;
           --options)       pkg_opts="$2"; shift 2;;
           --file)          pkg_file="$2"; shift 2;;
           --config)        pkg_cfg="$pkg_cfg:$2"; shift 2;;
           --config-path)   pkg_cfg_path="$2"; shift 2;;
           --cflags)        pkg_cflags="$pkg_cflags:$2"; shift 2;;
           --ldflags)       pkg_ldflags="$pkg_ldflags:$2"; shift 2;;
           --patch)         pkg_patches="$2"; shift 2;;
           --uses)          pkg_uses="$pkg_uses:$2"; shift 2;;
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    if [ "$use_verbose" == "true" ]
    then
        BLDR_VERBOSE=true
    fi

    if [[ $(echo "$pkg_opts" | grep -m1 -c "skip-compile" ) > 0 ]]
    then
        return
    fi

    local prefix="$BLDR_LOCAL_PATH/$pkg_ctry/$pkg_name/$pkg_vers"

    bldr_push_dir "$BLDR_BUILD_PATH/$pkg_ctry/$pkg_name/$pkg_vers"
    local build_path=$(bldr_locate_build_path $pkg_cfg_path)
    bldr_pop_dir

    #
    # handle TIFF specific build stuff
    #
    local output=$(bldr_get_stdout)
    bldr_push_dir "$BLDR_BUILD_PATH/$pkg_ctry/$pkg_name/$pkg_vers/$build_path"
    bldr_log_info "Moving to '$BLDR_BUILD_PATH/$pkg_ctry/$pkg_name/$pkg_vers/$build_path'"
    bldr_log_split

    # on OSX disable the tools from getting built since tiffgt.c fails to compile
    #
    if [ $BLDR_SYSTEM_IS_OSX != 0 ]
    then
        bldr_remove_file tools/Makefile
        echo "all:"      >  tools/Makefile
        echo " "         >> tools/Makefile
        echo "install: " >> tools/Makefile
        echo " "         >> tools/Makefile
        bldr_log_split
    fi
    bldr_pop_dir

    # call the standard BLDR compile method
    #
    bldr_compile_pkg         --category    "$pkg_ctry"    \
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
                             --patch       "$pkg_patches" \
                             --verbose     "$use_verbose"
    }

####################################################################################################
# build and install pkg as local module
####################################################################################################

bldr_build_pkg --category    "imaging"      \
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


