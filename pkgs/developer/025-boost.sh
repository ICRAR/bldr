#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="developer"
pkg_name="boost"
pkg_vers="1.49.0"

pkg_info="Boost provides free peer-reviewed portable C++ source libraries."

pkg_desc="Boost provides free peer-reviewed portable C++ source libraries.

We emphasize libraries that work well with the C++ Standard Library. 
Boost libraries are intended to be widely useful, and usable across a broad 
spectrum of applications. The Boost license encourages both commercial and 
non-commercial use.

We aim to establish 'existing practice' and provide reference implementations 
so that Boost libraries are suitable for eventual standardization. Ten Boost 
libraries are included in the C++ Standards Committee's Library Technical 
Report (TR1) and in the new C++11 Standard. C++11 also includes several more 
Boost libraries in addition to those from TR1. More Boost libraries are 
proposed for TR2."

pkg_file="boost_1_49_0.tar.bz2"
pkg_urls="http://sourceforge.net/projects/boost/files/boost/1.49.0/boost_1_49_0.tar.bz2/download"
pkg_opts="configure force-static"
pkg_reqs="zlib/latest bzip2/latest libicu/latest"
pkg_uses="m4/latest autoconf/latest automake/latest $pkg_reqs"
pkg_cflags=""
pkg_ldflags=""

pkg_cfg="variant=release link=static threading=multi runtime-link=static"
pkg_cfg="$pkg_cfg -s ICU_PATH=$BLDR_LOCAL_PATH/system/libicu/latest"
pkg_cfg="$pkg_cfg -s BZIP2_INCLUDE=$BLDR_LOCAL_PATH/system/bzip2/latest/include"
pkg_cfg="$pkg_cfg -s BZIP2_LIBPATH=$BLDR_LOCAL_PATH/system/bzip2/latest/lib"
pkg_cfg="$pkg_cfg -s ZLIB_INCLUDE=$BLDR_LOCAL_PATH/system/zlib/latest/include"
pkg_cfg="$pkg_cfg -s ZLIB_LIBPATH=$BLDR_LOCAL_PATH/system/zlib/latest/lib"

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
    local pkg_patches=""
    local pkg_cfg=""

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
           --cflags)        pkg_cflags="$pkg_cflags:$2"; shift 2;;
           --ldflags)       pkg_ldflags="$pkg_ldflags:$2"; shift 2;;
           --patch)         pkg_patches="$pkg_patches:$2"; shift 2;;
           --uses)          pkg_uses="$pkg_uses:$2"; shift 2;;
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

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
    
    # handle boost specific build setup
    #
    local prefix="$BLDR_LOCAL_PATH/$pkg_ctry/$pkg_name/$pkg_vers"
    bldr_push_dir "$BLDR_BUILD_PATH/$pkg_ctry/$pkg_name/$pkg_vers"
    local make_path=$(bldr_locate_makefile)
    bldr_pop_dir

    local output=$(bldr_get_stdout)  

    bldr_push_dir "$BLDR_BUILD_PATH/$pkg_ctry/$pkg_name/$pkg_vers/$make_path"
    bldr_log_info "Moving to '$BLDR_BUILD_PATH/$pkg_ctry/$pkg_name/$pkg_vers/$make_path'"
    bldr_log_split


    local env_flags=" "
    pkg_cfg=$(bldr_trim_list_str "$pkg_cfg")
    if [ "$pkg_cfg" != "" ] && [ "$pkg_cfg" != " " ] && [ "$pkg_cfg" != ":" ]
    then
        pkg_cfg=$(echo $pkg_cfg | bldr_split_str ":" | bldr_join_str " ")
    else
        pkg_cfg=""
    fi

    pkg_cflags=$(bldr_trim_list_str "$pkg_cflags")
    if [ "$pkg_cflags" != "" ] && [ "$pkg_cflags" != " " ]  && [ "$pkg_cflags" != ":" ]
    then
        pkg_mpath=$(echo $pkg_cflags | bldr_split_str ":" | bldr_join_str ";")
        env_flags='-DCMAKE_PREFIX_PATH="'$pkg_mpath'"'
    else
        pkg_cflags=""
    fi

    pkg_ldflags=$(bldr_trim_list_str "$pkg_ldflags")
    if [ "$pkg_ldflags" != "" ] && [ "$pkg_ldflags" != " " ] && [ "$pkg_ldflags" != ":" ]
    then
        pkg_env=$(echo $pkg_ldflags | bldr_split_str ":" | bldr_join_str " ")
        env_flags=$env_flags' '$pkg_env
    else
        pkg_ldflags=""
    fi

    bldr_log_cmd "./b2 --prefix="$prefix" $pkg_cfg $env_flags"
    bldr_log_split

    echo ./b2 --prefix="$prefix" $pkg_cfg $env_flags 
    bldr_log_split

    eval ./b2 --prefix="$prefix" $pkg_cfg $env_flags 
    bldr_log_split

    bldr_log_cmd "./b2 install"
    bldr_log_split

    eval ./b2 install 
    bldr_log_split
    bldr_pop_dir
}

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

