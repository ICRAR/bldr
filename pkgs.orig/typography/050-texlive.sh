#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="typography"
pkg_name="texlive"

pkg_info="TeX Live provides a live, up-to-date, TeX document production system."

pkg_desc="TeX Live provides a live, up-to-date, TeX document production system.  
It provides a comprehensive TeX system with binaries for most flavors of Unix, including 
GNU/Linux, and also Windows. It includes all the major TeX-related programs, macro 
packages, and fonts that are free software, including support for many languages 
around the world. "

pkg_default="2012"
pkg_variants=("2012")
pkg_distribs=("install-tl-unx.tar.gz")
pkg_mirrors=("http://mirror.ctan.org/systems/texlive/tlnet")

txl_opts="configure keep skip-install"
pkg_reqs="pkg-config"

pkg_uses=""
pkg_reqs=""

pkg_cfg=""
pkg_cflags=""
pkg_ldflags=""

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
           --default)       pkg_default="$2"; shift 2;;
           --info)          pkg_info="$2"; shift 2;;
           --description)   pkg_desc="$2"; shift 2;;
           --category)      pkg_ctry="$2"; shift 2;;
           --options)       pkg_opts="$2"; shift 2;;
           --file)          pkg_file="$2"; shift 2;;
           --config)        pkg_cfg="$pkg_cfg:$2"; shift 2;;
           --config-path)   pkg_cfg_path="$2"; shift 2;;
           --cflags)        pkg_cflags="$pkg_cflags:$2"; shift 2;;
           --ldflags)       pkg_ldflags="$pkg_ldflags:$2"; shift 2;;
           --patch)         pkg_patches="$pkg_patches:$2"; shift 2;;
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

    local prefix="$BLDR_LOCAL_PATH/$pkg_ctry/$pkg_name/$pkg_vers"
    local base="$BLDR_LOCAL_PATH/$pkg_ctry/$pkg_name"

    bldr_log_status "Building package '$pkg_name/$pkg_vers'"
    bldr_log_split
    
    bldr_log_info "Moving to build path: '$BLDR_BUILD_PATH/$pkg_ctry/$pkg_name/$pkg_vers' ..."
    bldr_log_split
    bldr_push_dir "$BLDR_BUILD_PATH/$pkg_ctry/$pkg_name/$pkg_vers"

    export TEXLIVE_INSTALL_PREFIX="$base"

    local profile="texlive-bldr.profile"
    echo "# TexLive Profile Generated by BLDR $BLDR_VERSION_STR"  >  $profile
    echo "#"                                                      >> $profile
    echo "selected_scheme scheme-medium"                          >> $profile
    echo "TEXDIR $base/$pkg_vers"                                 >> $profile
    if [ $BLDR_SYSTEM_IS_OSX == true ]
    then
      echo "binary_universal-darwin 1"                            >> $profile
    fi

    local output=$(bldr_get_stdout)
    local options="-scheme=medium -profile $profile -portable --persistent-downloads "

    if [ -f "./install-tl" ]
    then
        bldr_log_cmd "install-tl $options"
        bldr_log_split

        if [ $BLDR_VERBOSE != false ]
        then
            eval ./install-tl $options || bldr_bail "Failed to install package: '$prefix'"
            bldr_log_split
        else
            eval ./install-tl $options &> /dev/null || bldr_bail "Failed to install package: '$prefix'"
            bldr_log_split
        fi
    fi
    bldr_pop_dir
}

####################################################################################################
# register each pkg version with bldr
####################################################################################################

let pkg_idx=0
for pkg_vers in ${pkg_variants[@]}
do
    pkg_host=${pkg_mirrors[$pkg_idx]}
    pkg_file=${pkg_distribs[$pkg_idx]}
    pkg_urls="$pkg_host/$pkg_file"

    pkg_opts=txl_opts
    if [[ $BLDR_SYSTEM_IS_OSX == true ]]
    then
      pkg_opts+=" -EPATH+=$BLDR_LOCAL_ENV_PATH/$pkg_ctry/$pkg_name/$pkg_vers/bin/universal-darwin "

    elif [[ $BLDR_SYSTEM_IS_LINUX == true ]]
    then
      if [[ $BLDR_SYSTEM_IS_64BIT == true ]]
      then
        pkg_opts+=" -EPATH+=$BLDR_LOCAL_ENV_PATH/$pkg_ctry/$pkg_name/$pkg_vers/bin/x86_64-linux "
      else
        pkg_opts+=" -EPATH+=$BLDR_LOCAL_ENV_PATH/$pkg_ctry/$pkg_name/$pkg_vers/bin/i386-linux "
      fi
    fi

    bldr_register_pkg                  \
          --category    "$pkg_ctry"    \
          --name        "$pkg_name"    \
          --version     "$pkg_vers"    \
          --default     "$pkg_default"\
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

    let pkg_idx++
done

####################################################################################################