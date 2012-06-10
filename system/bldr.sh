#!/bin/bash

####################################################################################################
##
## License:    The MIT License
## 
## Copyright (c) 2012. Derek Gerstmann, The University of Western Australia.
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
## THE SOFTWARE.
##  
####################################################################################################

export BLDR_VERSION_MAJOR="1"
export BLDR_VERSION_MINOR="0"
export BLDR_VERSION_PATCH="0"
export BLDR_VERSION_STR="v$BLDR_VERSION_MAJOR.$BLDR_VERSION_MINOR.$BLDR_VERSION_PATCH"
export BLDR_VERBOSE=false
export BLDR_DEBUG=false

####################################################################################################

# setup project paths
BLDR_ABS_PWD="$( cd "$( dirname "$0" )/.." && pwd )"
BLDR_BASE_DIR="$( basename "$BLDR_ABS_PWD" )"
BLDR_ROOT_DIR="$( dirname "$BLDR_ABS_PWD" )"

# try one level up if we aren't resolving the root dir
if [ "$BLDR_BASE_DIR" != "bldr" ]
then
    BLDR_ABS_PWD="$( cd "$( dirname "$0" )/../.." && pwd )"
    BLDR_BASE_DIR="$( basename "$BLDR_ABS_PWD" )"
    BLDR_ROOT_DIR="$( dirname "$BLDR_ABS_PWD" )"
fi

####################################################################################################

# ensure we are run inside of the root dir
if [ "$BLDR_BASE_DIR" != "bldr" ]
then
    echo "Please execute package build script from within the 'bldr' subfolder: '$BLDR_ABS_PWD'!"
    exit 0
fi 

####################################################################################################

# setup system paths
export BLDR_SCRIPTS_DIR="$BLDR_ABS_PWD/scripts"
export BLDR_LOCAL_DIR="$BLDR_ABS_PWD/local"
export BLDR_CACHE_DIR="$BLDR_ABS_PWD/cache"
export BLDR_SYSTEM_DIR="$BLDR_ABS_PWD/system"
export BLDR_PKGS_DIR="$BLDR_ABS_PWD/pkgs"
export BLDR_MODULE_DIR="$BLDR_ABS_PWD/modules"
export BLDR_BUILD_DIR="$BLDR_ABS_PWD/build"
export BLDR_OS_LIB_EXT="a"

####################################################################################################

export BLDR_SYSTEM_IS_LINUX=$( uname -s | grep -c Linux )
if [ "$BLDR_SYSTEM_IS_LINUX" -eq 1 ]
then
    export BLDR_OS_NAME="lnx"
fi

export BLDR_SYSTEM_IS_OSX=$( uname -s | grep -c Darwin )
if [ "$BLDR_SYSTEM_IS_OSX" -eq 1 ]
then
    export BLDR_OS_NAME="osx"
    export MACOSX_DEPLOYMENT_TARGET=10.6
    export LDFLAGS="-arch x86_64 -isysroot /Developer/SDKs/MacOSX10.6.sdk"
    export CFLAGS="-arch x86_64 -isysroot /Developer/SDKs/MacOSX10.6.sdk"
fi

export BLDR_SYSTEM_IS_CENTOS=0
if [ "$BLDR_SYSTEM_IS_LINUX" -eq 1 ]
then
    if [ -e /etc/redhat-release ]
    then
        export BLDR_SYSTEM_IS_CENTOS=$( cat /etc/redhat-release | grep -c CentOS )
    fi
fi

if [ "$BLDR_OS_NAME" == "" ]
then
    echo "Operating system is unknown and not detected properly.  Please update detection routine!"
    exit 0
fi 

####################################################################################################

# setup the environment to support our own version of PKG_CONFIG
if [ -d "$BLDR_LOCAL_DIR/system/pkgconfig/latest/bin" ]
then
    export PKG_CONFIG=$BLDR_LOCAL_DIR/system/pkgconfig/latest/bin/pkg-config
    export PKG_CONFIG_PATH=$BLDR_LOCAL_DIR/system/pkgconfig/latest/lib/pkgconfig
fi

# setup the environment to support our own version of AUTOCONF
if [ -d "$BLDR_LOCAL_DIR/system/autoconf/latest/bin" ]
then
    export PATH="$BLDR_LOCAL_DIR/system/autoconf/latest/bin:$PATH"
fi

# setup the environment to support our own version of AUTOMAKE
if [ -d "$BLDR_LOCAL_DIR/system/automake/latest/bin" ]
then
    export PATH="$BLDR_LOCAL_DIR/system/automake/latest/bin:$PATH"
fi

# setup the environment to support our own version of GETTEXT
if [ -d "$BLDR_LOCAL_DIR/system/gettext/latest/bin" ]
then
    export PATH="$BLDR_LOCAL_DIR/system/gettext/latest/bin:$PATH"
fi

# setup the environment to support our own version of GLIB
if [ -d "$BLDR_LOCAL_DIR/system/glib/latest/bin" ]
then
    export PATH="$BLDR_LOCAL_DIR/system/glib/latest/bin:$PATH"
fi

####################################################################################################

function bldr_make_lowercase()
{
    echo $1 | tr '[:upper:]' '[:lower:]'
}

function bldr_make_uppercase()
{
    echo $1 | tr '[:lower:]' '[:upper:]'
}

function bldr_resolve_path()
{
    cd "$1" 2>/dev/null || return $? 
    local resolved="`pwd -P`"
    echo "$resolved"
}

function bldr_echo()
{
    echo "${@}"
}

function bldr_report()
{
    local ts=$(date "+%Y-%m-%d-%H:%M:%S")
    echo "[ ${ts} ] ${@}"
}

function bldr_exec()
{
    eval "${@}"
}

function bldr_output_hline()
{
    echo "---------------------------------------------------------------------------------------------------------------"
}

function bldr_trim_str
{
    echo "${@}" | sed 's/^ *//g' | sed 's/ *$//g'
}

function bldr_trim_list_str
{
    echo "${@}" | sed 's/^:*//g' | sed 's/:*$//g'
}

function bldr_trim_url_str
{
    echo "${@}" | sed 's/^;*//g' | sed 's/;*$//g'
}

function bldr_match_str
{
    local $str
    local $fnd
    local cnt=$(echo $str | grep -c '^'$fnd':')
    echo "$cnt"
}

function bldr_locate_makefile
{
    local make_path="."
    local mk_paths=". ./build ../build .. ../src ../source"
    for path in ${mk_paths}
    do
        if [ -f "$path/Makefile" ]
        then
            make_path="$path"
            break
        fi
    done
    echo "$make_path"
}

function bldr_quote_str
{
    local filename=$1

    sed $filename \
        -e 's#\\#\\\\#' \
        -e 's#/#\\/#' \
        -e 's#\.#\\.#' \
        -e 's#\*#\\*#' \
        -e 's#\[#\\[#'

    return $?
}

function bldr_split_str
{
    local BLDR_DEFAULT_DELIMITER=" "

    local a_delimiter="${1:-$BLDR_DEFAULT_DELIMITER}"
    local a_inputfile="$2"

    awk -F "$a_delimiter" \
    '{  for(i = 1; i <= NF; i++) {
            print $i
        }
    }' $a_inputfile

    return $?
}

function bldr_join_str
{
    local BLDR_DEFAULT_DELIMITER=" "

    local a_delimiter="${1:-$BLDR_DEFAULT_DELIMITER}"
    local a_inputfile="$2"

    awk -v usersep="$a_delimiter" '
    BEGIN{
        sep=""; # Start with no bldr_output_hline (before the first item)
    }
    {
        printf("%s%s", sep, $0);
        (NR == 1) && sep = usersep; # Separator is set after the first item.
    }
    END{
        print "" # Print a new line at the end.
    }' $a_inputfile
    
    return $?
}

function bldr_output_header()
{
    local msg=$@
    bldr_output_hline
    bldr_report "${msg}"
    bldr_output_hline
}

function bldr_bail
{
    local msg=$@

    bldr_report ""

    bldr_output_hline
    bldr_report "ERROR: ${msg}. Exiting..."
    bldr_output_hline

    exit 1
}

function try
{
    $@
    if test $? -ne 0 ; then
        bldr_bail "$@"
    fi
}

function bldr_exit_on_failure
{
    if test $? -ne 0 ; then
        bldr_bail "$1"
    fi
}

function bldr_clone()
{
    local url=$1
    local dir=$2

    local cmd="$(which wget)"
    if [ -e $cmd ];
    then
        cmd="git bldr_clone"
        $cmd $url $dir || bldr_bail "Failed to bldr_clone '$url' into '$dir'"
    else
        bldr_bail "Failed to locate 'git' command!  Please install this command line utility!"
    fi
    bldr_output_hline
}

function bldr_checkout()
{
    local url=$1
    local dir=$2

    url="${url/svn/http}"
    local cmd="$(which svn)"
    if [ -e $cmd ];
    then
        cmd="svn export"
        $cmd $url $dir || bldr_bail "Failed to bldr_checkout '$url' into '$dir'"
    else
        bldr_bail "Failed to locate 'svn' command!  Please install this command line utility!"
    fi
    bldr_output_hline
}

function bldr_fetch() 
{
    local url=$1
    local archive=$2
    local dir=$3

    local usepipe=0
    local cmd="$(which wget)"
    if [ ! -e $cmd ];
    then
        cmd="$(which curl)"
        if [ -e $cmd ];
        then
            cmd="curl -f -L -O"
            usepipe=1
        else
            bldr_bail "Failed to locate either 'wget' or 'curl' for fetching packages!  Please install one of these utilties!"
        fi
    else
        cmd="wget --progress=dot -O"
    fi

    if [ ! -e $archive ]; then
        bldr_report "Fetching '$archive'..."
        bldr_output_hline
        if [ "$usepipe" -eq 1 ]
        then
            echo "> $cmd $url > $archive"
            bldr_output_hline
            $cmd $url > $archive
        else
            echo "> $cmd $archive $url"
            bldr_output_hline
            $cmd $archive $url
        fi
        bldr_output_hline
        bldr_report "Downloaded '$url' to '$archive'..."
    fi
}

function bldr_is_valid_archive()
{
    local is=0
    local archive=$1
    if [ -f $archive ] ; then
       case $archive in
        *.tar.bz2)  is=1;;
        *.tar.gz)   is=1;;
        *.tar.xz)   is=1;;
        *.bz2)      is=1;;
        *.rar)      is=1;;
        *.gz)       is=1;;
        *.tar)      is=1;;
        *.tbz2)     is=1;;
        *.tgz)      is=1;;
        *.zip)      is=1;;
        *.Z)        is=1;;
        *.7z)       is=1;;
        *)          is=0;;
       esac    
    fi
    echo "$is"
}

function bldr_extract_archive()
{
    local archive=$1
    local extr=$(which tar)
    echo "-- Extracting '$archive'"

    if [ -e $BLDR_LOCAL_DIR/gtar/latest/bin/tar ]
    then
        extr=$BLDR_LOCAL_DIR/gtar/latest/bin/tar
    fi

    if [ -f $archive ] ; then
       case $archive in
        *.tar.bz2)  eval $extr xvjf ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.tar.gz)   eval $extr xvzf ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.tar.xz)   eval $extr Jxvf ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.bz2)      eval bunzip2 ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.rar)      eval unrar x ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.gz)       eval gunzip ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.tar)      eval $extr xvf ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.tbz2)     eval $extr xvjf ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.tgz)      eval $extr xvzf ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.zip)      eval unzip -uo ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.Z)        eval uncompress ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *.7z)       eval 7z x ${archive} || bldr_bail "Failed to extract archive '${archive}'";;
        *)          bldr_bail "Failed to extract archive '${archive}'";;
       esac    
    fi
}

function bldr_strip_archive_ext()
{
    local archive=$1
    local result=""

    if [ -f $archive ] ; then
       case $archive in
        *.tar.bz2)  result=$(echo ${archive%.tar.bz2} );;
        *.tar.gz)   result=$(echo ${archive%.tar.gz} );;
        *.tar.xz)   result=$(echo ${archive%.tar.xz} );;
        *.bz2)      result=$(echo ${archive%.bz2} );;
        *.rar)      result=$(echo ${archive%.rar} );;
        *.gz)       result=$(echo ${archive%.gz} );;
        *.tar)      result=$(echo ${archive%.tar} );;
        *.tbz2)     result=$(echo ${archive%.tbz2} );;
        *.tgz)      result=$(echo ${archive%.tgz} );;
        *.zip)      result=$(echo ${archive%.zip} );;
        *.Z)        result=$(echo ${archive%.Z} );;
        *.7z)       result=$(echo ${archive%.7z} );;
        *)          bldr_bail "Failed to extract archive contents '${archive}'";;
       esac    
    fi

    echo $result
}

function bldr_list_archive()
{
    local archive=$1
    local extr=$(which tar)
    local result=""

    if [ -e $BLDR_LOCAL_DIR/gtar/latest/bin/tar ]
    then
        extr=$BLDR_LOCAL_DIR/gtar/latest/bin/tar
    fi

    if [ -f $archive ] ; then
       case $archive in
        *.tar.bz2)  result=$(eval $extr tjf ${archive} );;
        *.tar.gz)   result=$(eval $extr tzf ${archive} );;
        *.tar.xz)   result=$(eval $extr Jtf ${archive} );;
        *.tar)      result=$(eval $extr tf ${archive} );;
        *.tbz2)     result=$(eval $extr tjf ${archive} );;
        *.tgz)      result=$(eval $extr tzf ${archive} );;
        *.zip)      result=$(eval unzip -l ${archive} );;
        *)          bldr_bail "Failed to extract archive contents '${archive}'";;
       esac    
    fi

    local basedir=$(echo "$result" | grep -E "^[^/]*(/)$" )

    if [ "$basedir" == "" ]
    then
        basedir=$(bldr_strip_archive_ext "$archive")
    fi

    local listing=$(basename $basedir)
    echo "$listing"
}

function bldr_make_dir()
{
    local dir=$1
    echo "-- Creating '$dir'"
    mkdir -p ${dir} || bldr_bail "Failed to create directory '${dir}'"
}

function bldr_remove_dir()
{
    local dir=$1
    local force=$2
    if [ "$dir" = "/" ] 
    then
        bldr_bail "Invalid directory name requested for removal: '${dir}'"
    fi

    echo "-- Removing '$dir'"
    if [ ${force} ]; then
        rm -r ${dir}  || bldr_bail "Failed to remove directory '${dir}'"
    else
        if [ -d "${dir}" ]; then
            chmod -R +rw ${dir} || bldr_bail "Failed to remove directory '${dir}'"
            rm -r ${dir}  || bldr_bail "Failed to remove directory '${dir}'"
        fi
    fi
}

function bldr_push_dir()
{
    local dir=$1
    pushd ${dir} > /dev/null || bldr_bail "Failed to push directory '${dir}'"
}

function bldr_pop_dir()
{
    local dir=$1
    popd  > /dev/null  || bldr_bail "Failed to pop directory!"
}

function bldr_move_file()
{
    local src=$1
    local dst=$2
    mv ${src} ${dst}  || bldr_bail "Failed to move file!"
}

function bldr_remove_file()
{
    local src=$1
    rm ${src} || bldr_bail "Failed to remove file!"
}

function bldr_copy_file()
{
    local src=$1
    local dst=$2
    cp ${src} ${dst}  || bldr_bail "Failed to copy file!"
}

function bldr_make_archive()
{
    local archive=$1
    local dir=$2
    
    tar cjf "${archive}" "${dir}" || bldr_bail "Failed to create archive!"
}

function bldr_cursor_pos()
{
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    echo -en "\033[6n" > /dev/tty
    # tput u7 > /dev/tty    # when TERM=xterm (and relatives)
    
    IFS=';' read -r -d R -a pos
    stty $oldstty
    
    # change from one-based to zero based so they work with: tput cup $row $col
    local row=$((${pos[0]:2} - 1))    # strip off the esc-[
    local col=$((${pos[1]} - 1))
    
    echo "$row $col"
}

function bldr_copy_dir()
{
    local src=$1
    local dst=$2

    echo "-- Copying '$src' to '$dst' ..."
    if [ "$BLDR_SYSTEM_IS_LINUX" -eq 1 ]
    then
        # echo cp -TRv $src $dst
        cp -TR $src $dst || bldr_bail "Failed to copy from '$src' to '$dst'"
    elif [ "$BLDR_SYSTEM_IS_OSX" -eq 1 ]
    then
        # echo ditto -v $src $dst
        ditto $src $dst || bldr_bail "Failed to copy from '$src' to '$dst'"
    fi
}

####################################################################################################

function bldr_build_all()
{
    local dir="${1}"
    if [[ -d $dir ]]
    then
        local builder
        for builder in "$dir"/*
        do
            if [[ -f $builder ]]
            then
                eval $builder
            fi
        done
    fi
}

function bldr_has_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_opts=""

    while true ; do
        case "$1" in
           --name)          pkg_name="$2"; shift 2;;
           --version)       pkg_vers="$2"; shift 2;;
           --category)      pkg_ctry="$2"; shift 2;;
           --options)       pkg_opts="$2"; shift 2;;
           * )              break ;;
        esac
    done

    local existing=false

    if [ -d "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers" ]
    then
        existing=true
    fi

    echo "$existing"
}

function bldr_setup_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           -- )             shift; break ;;
           * )              break ;;
        esac
    done

    bldr_output_hline
    bldr_report "Setting up package '$pkg_name/$pkg_vers' for '$BLDR_OS_NAME' ... "
    bldr_output_hline
    
    bldr_make_dir "$BLDR_BUILD_DIR"
    bldr_push_dir "$BLDR_BUILD_DIR"

    bldr_output_hline
    if [ -d "$pkg_name/$pkg_vers" ]
    then
        bldr_report "Removing stale build '$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers'"
        bldr_output_hline
        bldr_remove_dir "$pkg_name/$pkg_vers"
        bldr_output_hline
    fi
    bldr_pop_dir

    if [ -f "$BLDR_MODULE_DIR/$pkg_ctry/$pkg_name/$pkg_vers" ]
    then
        bldr_report "Removing stale module '$BLDR_MODULE_DIR/$pkg_ctry/$pkg_name/$pkg_vers'"
        bldr_output_hline
        bldr_remove_file "$BLDR_MODULE_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
    fi

}

function bldr_fetch_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           -- )             shift; break ;;
           * )              break ;;
        esac
    done

    # if a local copy doesn't exist, grab the pkg from the url
    bldr_make_dir "$BLDR_CACHE_DIR"
    bldr_push_dir "$BLDR_CACHE_DIR"
    bldr_output_hline
    if [ ! -f "$pkg_file" ]
    then
        local pkg_url_list=$(echo $pkg_urls | bldr_split_str ';')
        for url in ${pkg_url_list}
        do
            bldr_report "Retrieving package '$pkg_name' from '$url'"
            bldr_output_hline

            if [[ $(echo "$url" | grep -c 'http://') == 1 ]]
            then
                bldr_fetch $url $pkg_file 
            fi

            if [[ $(echo "$url" | grep -c 'git://') == 1 ]]
            then
                bldr_clone $url $pkg_name 
                if [ -d $pkg_name ]
                then
                    bldr_output_hline
                    bldr_report "Archiving package '$pkg_file' from '$pkg_name'"
                    bldr_make_archive $pkg_file $pkg_name
                    bldr_output_hline
                fi
            fi

            if [[ $(echo "$url" | grep -c 'svn://') == 1 ]]
            then
                bldr_checkout $url $pkg_name 
                if [ -d $pkg_name ]
                then
                    bldr_output_hline
                    bldr_report "Archiving package '$pkg_file' from '$pkg_name'"
                    bldr_make_archive $pkg_file $pkg_name
                    bldr_output_hline
                fi
            fi

            if [ -e $pkg_file ]; then
                break;
            fi
        done
    fi
    bldr_pop_dir

    # extract any pkg archives
    if [[ $(bldr_is_valid_archive "$BLDR_CACHE_DIR/$pkg_file") == 1 ]]
    then
        bldr_report "Migrating package '$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$pkg_file'"
        bldr_output_hline
        if [ ! -d "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name" ]
        then
            bldr_make_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name"
            bldr_output_hline
        fi
        bldr_copy_file "$BLDR_CACHE_DIR/$pkg_file" "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_file"

        bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name"
        local archive_listing=$(bldr_list_archive $pkg_file)
        bldr_report "Extracting package '$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_file' to '$archive_listing'"
        bldr_output_hline
        bldr_extract_archive $pkg_file
        bldr_move_file $archive_listing $pkg_vers
        bldr_remove_file "$pkg_file"
        bldr_pop_dir
    fi
}

function bldr_boot_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
    bldr_output_hline

    pkg_reqs=$(bldr_trim_list_str "$pkg_reqs")
    if [ "$pkg_reqs" != "" ] && [ "$pkg_reqs" != " " ] && [ "$pkg_reqs" != ":" ]
    then
        pkg_reqs=$(echo $pkg_reqs | bldr_split_str ":" | bldr_join_str " ")
    else
        pkg_reqs=""
    fi

    local cmd_mod="$(which modulecmd)"
    if [[ "$pkg_reqs" != "0" && "$cmd_mod" != "" ]]
    then
        module use "$BLDR_MODULE_DIR/$pkg_ctry"
        bldr_output_hline
        for require in ${pkg_reqs}
        do
            bldr_report "Loading required module '$require' ..."
            module load $require
        done
        bldr_output_hline
    fi

    # bootstrap package
    if [ ! -f "./configure" ]
    then
        if [ -f "./bootstrap" ]
        then
            bldr_report "Booting package '$pkg_name'"
            bldr_output_hline
            ./bootstrap
            bldr_output_hline
        fi
        if [ -f "./bootstrap.sh" ]
        then 
            bldr_report "Booting package '$pkg_name'"
            bldr_output_hline
            ./bootstrap.sh
            bldr_output_hline
        fi
        if [ -f "./autogen.sh" ]
        then 
            bldr_report "Booting package '$pkg_name'"
            bldr_output_hline
            ./autogen.sh
            bldr_output_hline
        fi
    fi
    bldr_pop_dir
}

function bldr_cmake_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    bldr_make_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers/build"
    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers/build"

    bldr_output_hline
  
    local prefix="$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers"

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

    env_flags="$env_flags $pkg_cfg"

    local cmake_src_path=".."
    local src_paths=".. ../src ../source"
    for path in ${src_paths}
    do
        if [ -f "$path/CMakeLists.txt" ] 
        then
            cmake_src_path="$path"
            break
        fi
    done

    bldr_report "Configuring package '$pkg_name' from source folder '$cmake_src_path' ..."
    bldr_output_hline

    local cmake_exec="$BLDR_LOCAL_DIR/cmake/latest/bin/cmake"
    local cmake_mod="-DCMAKE_MODULE_PATH=$BLDR_LOCAL_DIR/cmake/latest/share/cmake-2.8/Modules"
    local cmake_pre="-DCMAKE_INSTALL_PREFIX=$prefix"
    if [ "$BLDR_SYSTEM_IS_OSX" -eq 1 ]
    then
        cmake_pre="$cmake_pre -DCMAKE_OSX_ARCHITECTURES=x86_64"
    fi

    echo $cmake_exec $cmake_mod $cmake_pre $env_flags $cmake_src_path
    bldr_output_hline

    eval $cmake_exec $cmake_mod $cmake_pre $env_flags $cmake_src_path || bldr_bail "Failed to configure: '$prefix'"
    bldr_output_hline

    bldr_report "Done configuring package '$pkg_name'"

    bldr_pop_dir
}

function bldr_config_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    local prefix="$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers"

    local use_cmake=1
    local has_cmake=0

    local use_amake=0
    local has_amake=0

    if [ -f "./CMakeLists.txt" ] || [ -f "./src/CMakeLists.txt" ] || [ -f "./source/CMakeLists.txt" ]
    then
        has_cmake=1
    fi    

    if [ -f "./configure" ] || [ -f "./Configure" ]
    then
        has_amake=1
    fi

    if [[ $(echo $pkg_opts | grep -c 'cmake' ) > 0 ]]
    then
        use_cmake=1
        use_amake=0
        has_amake=0
    fi

    if [[ $(echo $pkg_opts | grep -c 'configure' ) > 0 ]]
    then
        use_cmake=0
        has_cmake=0
        use_amake=1
    fi

    if [ $use_cmake != 0 ] && [ $has_cmake != 0 ]
    then
        bldr_pop_dir
        bldr_cmake_pkg --category   "$pkg_ctry"     \
                       --name       "$pkg_name"     \
                       --version    "$pkg_vers"     \
                       --file       "$pkg_file"     \
                       --url        "$pkg_urls"     \
                       --requires   "$pkg_reqs"     \
                       --options    "$pkg_opts"     \
                       --cflags     "$pkg_cflags"   \
                       --ldflags    "$pkg_ldflags"  \
                       --config     "$pkg_cfg"
    else
        use_amake=1
    fi

    if [ $use_amake != 0 ] && [ $has_amake != 0 ]
    then
        local env_flags=" "

        if [ "$BLDR_SYSTEM_IS_CENTOS" -eq 1 ]
        then
            if [ "$pkg_cflags" != "" ] && [ "$pkg_cflags" != " " ]  && [ "$pkg_cflags" != ":" ]
            then
                pkg_cflags="$pkg_cflags":-I/usr/include
                pkg_ldflags="$pkg_ldflags":-L/usr/lib64:-L/usr/lib
            fi
        fi

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
            pkg_cflags=$(echo $pkg_cflags | bldr_split_str ":" | bldr_join_str " ")
            env_flags='CXXFLAGS="'$pkg_cflags'" CPPFLAGS="'$pkg_cflags'" CFLAGS="'$pkg_cflags'"'
        else
            pkg_cflags=""
        fi

        pkg_ldflags=$(bldr_trim_list_str "$pkg_ldflags")
        if [ "$pkg_ldflags" != "" ] && [ "$pkg_ldflags" != " " ] && [ "$pkg_ldflags" != ":" ]
        then
            pkg_ldflags=$(echo $pkg_ldflags | bldr_split_str ":" | bldr_join_str " ")
            env_flags=$env_flags' LDFLAGS="'$pkg_ldflags'"'
        else
            pkg_ldflags=""
        fi
        
        bldr_report "Configuring package '$pkg_name' ..."
        bldr_output_hline

        echo "> ./configure --prefix=\"$prefix\" $pkg_cfg $env_flags"
        bldr_output_hline

        eval ./configure --prefix="$prefix" $pkg_cfg $env_flags || bldr_bail "Failed to configure: '$prefix'"
        bldr_output_hline

        bldr_report "Done configuring package '$pkg_name'"
        bldr_pop_dir
    fi
}

function bldr_compile_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    local prefix="$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers"

    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
    local make_path=$(bldr_locate_makefile)
    bldr_pop_dir

    # build using make if a makefile exists
    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$make_path"
    echo "Moving to '$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$make_path'"
    if [ -f "Makefile" ] || [ -f "$make_path/Makefile" ]
    then
        bldr_report "Building package '$pkg_name'"
        bldr_output_hline
        make  || bldr_bail "Failed to build package: '$prefix'"
        bldr_output_hline
    fi
    bldr_pop_dir
}

function bldr_install_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    local prefix="$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers"

    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
    local make_path=$(bldr_locate_makefile)
    bldr_pop_dir

    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$make_path"

    # extract the makefile rule names and filter out empty lines and comments
    local rules=$(make -pn | grep -v ^$ | grep -v ^# | grep -c '^install:')

    # install using make if an 'install' rule exists
    if [[ $(echo "$rules") > 0 ]]
    then
        bldr_report "Installing package '$pkg_name'"
        bldr_output_hline
        make install || bldr_bail "Failed to install package: '$prefix'"
        bldr_output_hline
    fi

    bldr_pop_dir
}

function bldr_migrate_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    local prefix="$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers"

    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
    local make_path=$(bldr_locate_makefile)
    bldr_pop_dir

    # build using make if a makefile exists
    bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$make_path"
    local bin_paths="lib bin lib32 lib64"
    for path in ${bin_paths}
    do
        # move product into external os specific path
        if [ -d "$prefix/$path" ]
        then
            if [ -d "$prefix/$path/pkgconfig" ] && [ -d "$PKG_CONFIG_PATH" ]
            then
                bldr_report "Installing package config from '$prefix/$path/pkgconfig' for '$pkg_name'"
                bldr_output_hline
                cp -v $prefix/$path/pkgconfig/*.pc "$PKG_CONFIG_PATH" || bldr_bail "Failed to copy pkg-config into directory: $PKG_CONFIG_PATH"
                bldr_output_hline
            fi
        fi
    done
    bldr_pop_dir

    if [[ $(echo $pkg_opts | grep -c 'migrate-raw-headers' ) > 0 ]]
    then
        bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
        local inc_paths="include inc man share"
        for path in ${inc_paths}
        do
            # move product into external path
            if [ -d "$path" ]
            then
                bldr_report "Migrating build files from '$path' for '$pkg_name'"
                bldr_output_hline
                bldr_make_dir "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$path"
                bldr_copy_dir "$path" "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$path" || bldr_bail "Failed to copy shared files into directory: $BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$path"
                bldr_output_hline
            fi
        done
        bldr_pop_dir
    fi    

    if [[ $(echo $pkg_opts | grep -c 'migrate-build-libs' ) > 0 ]]
    then
        bldr_push_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
        local inc_paths="build"
        for path in ${inc_paths}
        do
            # move product into external path
            if [ -d "$path" ]
            then
                bldr_report "Migrating build libraries from '$path' for '$pkg_name'"
                bldr_output_hline
                bldr_make_dir "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$path"
                bldr_output_hline
                eval cp -v "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$path/*.$BLDR_OS_LIB_EXT" "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$path" || bldr_bail "Failed to copy shared files into directory: $BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers/$path"
            fi
        done
        bldr_pop_dir
    fi    

    bldr_report "Linking local '$pkg_name/$pkg_vers' as '$pkg_name/latest' ..."
    bldr_output_hline
    if [ -e "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/latest" ]
    then
        bldr_remove_file "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/latest"
    fi
    ln -sv "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers" "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/latest"
    bldr_output_hline    

    if [[ $(echo $pkg_opts | grep -c 'keep' ) > 0 ]]
    then
        bldr_report "Keeping package build directory for '$pkg_name/$pkg_vers'"
    else
        bldr_report "Removing package build directory for '$pkg_name/$pkg_vers'"
        bldr_output_hline
        bldr_remove_dir "$BLDR_BUILD_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
        bldr_output_hline
    fi

}

function bldr_modulate_pkg()
{
    local pkg_ctry="common"
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    local prefix="$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers"
    local tstamp=$(date "+%Y-%m-%d-%H:%M:%S")

    local module_dir="$BLDR_MODULE_DIR/$pkg_ctry/$pkg_name"
    local module_file="$BLDR_MODULE_DIR/$pkg_ctry/$pkg_name/$pkg_vers"

    bldr_push_dir "$BLDR_LOCAL_DIR/$pkg_ctry/$pkg_name/$pkg_vers"

    bldr_report "Modulating '$pkg_ctry' package '$pkg_name/$pkg_vers'"
    bldr_output_hline
    bldr_make_dir "$module_dir"
    bldr_output_hline

    local pkg_title=$(bldr_make_uppercase $pkg_name)
    pkg_title=$(echo $pkg_title|sed 's/-/_/g')

    pkg_cfg=$(bldr_trim_list_str "$pkg_cfg")
    if [ "$pkg_cfg" != "" ] && [ "$pkg_cfg" != " " ] && [ "$pkg_cfg" != ":" ]
    then
        pkg_cfg="$(echo $pkg_cfg | bldr_split_str ":" | bldr_join_str " ")"
    else
        pkg_cfg=""
    fi

    pkg_cflags=$(bldr_trim_list_str "$pkg_cflags")
    if [ "$pkg_cflags" != "" ] && [ "$pkg_cflags" != " " ]  && [ "$pkg_cflags" != ":" ]
    then
        pkg_cflags="$(echo $pkg_cflags | bldr_split_str ":" | bldr_join_str " ")"
    else
        pkg_cflags=""
    fi

    pkg_ldflags=$(bldr_trim_list_str "$pkg_ldflags")
    if [ "$pkg_ldflags" != "" ] && [ "$pkg_ldflags" != " " ] && [ "$pkg_ldflags" != ":" ]
    then
        pkg_ldflags="$(echo $pkg_ldflags | bldr_split_str ":" | bldr_join_str " ")"
    else
        pkg_ldflags=""
    fi

    pkg_opts=$(bldr_trim_list_str "$pkg_opts")
    if [ "$pkg_opts" != "" ] && [ "$pkg_opts" != " " ] && [ "$pkg_opts" != ":" ]
    then
        pkg_opts="$(echo $pkg_opts | bldr_split_str ":" | bldr_join_str " ")"
    else
        pkg_opts=""
    fi

    pkg_urls=$(bldr_trim_list_str "$pkg_urls")
    pkg_urls=$(bldr_trim_url_str "$pkg_urls")
    if [ "$pkg_urls" != "" ] && [ "$pkg_urls" != " " ] && [ "$pkg_urls" != ":" ]
    then
        pkg_urls="$(echo $pkg_urls | bldr_split_str ";" | bldr_join_str " ")"
    else
        pkg_urls=""
    fi

    pkg_reqs=$(bldr_trim_list_str "$pkg_reqs")
    if [ "$pkg_reqs" != "" ] && [ "$pkg_reqs" != " " ] && [ "$pkg_reqs" != ":" ]
    then
        pkg_reqs=$(echo $pkg_reqs | bldr_split_str ":" | bldr_join_str " ")
    else
        pkg_reqs=""
    fi

    local pkg_env_prefix=$(echo $pkg_title | bldr_join_str "_")

    echo "#%Module 1.0"                                     >  $module_file
    echo "#"                                                >> $module_file
    echo "# $pkg_title $pkg_vers module for use with 'environment-modules' package." >> $module_file
    echo "#"                                                >> $module_file
    echo "# Generated by BLDR $BLDR_VERSION_STR on $tstamp" >> $module_file
    echo "# -- PkgCategory:  '$pkg_ctry'"                   >> $module_file
    echo "# -- PkgName:      '$pkg_name'"                   >> $module_file
    echo "# -- PkgVersion:   '$pkg_vers'"                   >> $module_file
    echo "# -- PkgInfo:      '$pkg_info'"                   >> $module_file
    echo "# -- PkgFile:      '$pkg_file'"                   >> $module_file
    echo "# -- PkgUrls:      '$pkg_urls'"                   >> $module_file
    echo "# -- PkgOptions:   '$pkg_opts'"                   >> $module_file
    echo "# -- PkgRequires:  '$pkg_reqs'"                   >> $module_file
    echo "# -- PkgCFlags:    '$pkg_cflags'"                 >> $module_file
    echo "# -- PkgLDFlags:   '$pkg_ldflags'"                >> $module_file
    echo "# -- PkgConfig:    '$pkg_cfg'"                    >> $module_file
    echo "#"                                                >> $module_file
    echo ""                                                 >> $module_file
    echo "proc ModulesHelp { } { "                          >> $module_file
    echo "    puts stderr \"Provides module environment support for $pkg_title v$pkg_vers.\"" >> $module_file
    echo "    puts stderr \" \""                            >> $module_file

    local line_string=""
    local pkg_desc_lines=$(echo $pkg_desc | bldr_split_str ' \n')
    for word in ${pkg_desc_lines}
    do
        line_string="$line_string $word"
        if [[ ${#line_string} -ge 78 ]]
        then
            line_string=$(bldr_trim_str $line_string)
            echo "    puts stderr \"$line_string\""         >> $module_file
            line_string=""
        fi
    done

    if [[ ${#line_string} -ge 1 ]]
    then
        echo "    puts stderr \"$line_string\""             >> $module_file
        line_string=""
    fi
    echo "    puts stderr \" \""                            >> $module_file
    echo "}"                                                >> $module_file
    echo ""                                                 >> $module_file
    echo "module-whatis \"$pkg_info\""                      >> $module_file
    echo ""                                                 >> $module_file

    if [ "$pkg_reqs" != "" ]
    then
        for require in ${pkg_reqs}
        do
            echo "prereq $require" >> $module_file
        done
        echo ""                                                 >> $module_file
    fi

    # pkg specific environment settings
    echo "setenv $pkg_title""_VERSION                       $pkg_vers"       >> $module_file

    if [ -d "$prefix/include" ]
    then
        echo "setenv $pkg_title""_INCLUDE_PATH              $prefix/include" >> $module_file
    fi

    if [ -d "$prefix/inc" ]
    then
        echo "setenv $pkg_title""_INCLUDE_PATH              $prefix/inc"     >> $module_file
    fi

    if [ -d "$prefix/bin" ]
    then
        echo "setenv $pkg_title""_BIN_PATH                  $prefix/bin"     >> $module_file
    fi

    if [ -d "$prefix/sbin" ]
    then
        echo "setenv $pkg_title""_SBIN_PATH                 $prefix/sbin"    >> $module_file
    fi

    if [ -d "$prefix/lib" ]
    then
        echo "setenv $pkg_title""_LIB_PATH                  $prefix/lib"     >> $module_file
    fi

    if [ -d "$prefix/lib32" ]
    then
        echo "setenv $pkg_title""_LIB32_PATH                $prefix/lib32"   >> $module_file
    fi

    if [ -d "$prefix/lib64" ]
    then
        echo "setenv $pkg_title""_LIB64_PATH                $prefix/lib64"   >> $module_file
    fi

    if [ -d "$prefix/man" ]
    then
        echo "setenv $pkg_title""_MAN_PATH                  $prefix/man"     >> $module_file
    fi

    if [ -d "$prefix/share" ]
    then
        echo "setenv $pkg_title""_SHARE_PATH                $prefix/share"   >> $module_file
    fi

    if [ -d "$prefix/etc" ]
    then
        echo "setenv $pkg_title""_CONFIG_PATH               $prefix/etc"     >> $module_file
    fi

    echo ""                                                      >> $module_file

    # system specific environment settings

    if [ -d "$prefix/bin" ]
    then
        echo "prepend-path PATH                 $prefix/bin"     >> $module_file
    fi

    if [ -d "$prefix/sbin" ]
    then
        echo "prepend-path PATH                 $prefix/sbin"    >> $module_file
    fi

    if [ -d "$prefix/inc" ]
    then
        echo "prepend-path C_INCLUDE_PATH       $prefix/inc"     >> $module_file
        echo "prepend-path CPLUS_INCLUDE_PATH   $prefix/inc"     >> $module_file
    fi

    if [ -d "$prefix/include" ]
    then
        echo "prepend-path C_INCLUDE_PATH       $prefix/include" >> $module_file
        echo "prepend-path CPLUS_INCLUDE_PATH   $prefix/include" >> $module_file
        echo "prepend-path CPATH                $prefix/include" >> $module_file
        echo "prepend-path FPATH                $prefix/include" >> $module_file
    fi

    if [ -d "$prefix/lib" ]
    then
        echo "prepend-path LD_LIBRARY_PATH      $prefix/lib"     >> $module_file
        echo "prepend-path LIBRARY_PATH         $prefix/lib"     >> $module_file
    fi

    if [ -d "$prefix/lib32" ]
    then
        echo "prepend-path LD_LIBRARY_PATH      $prefix/lib32"   >> $module_file
        echo "prepend-path LIBRARY_PATH         $prefix/lib32"   >> $module_file
    fi

    if [ -d "$prefix/lib64" ]
    then
        echo "prepend-path LD_LIBRARY_PATH      $prefix/lib64"   >> $module_file
        echo "prepend-path LIBRARY_PATH         $prefix/lib64"   >> $module_file
    fi

    if [ -d "$prefix/man" ]
    then
        echo "prepend-path MANPATH              $prefix/man"     >> $module_file
    fi

    if [ -d "$prefix/locale" ]
    then
        echo "prepend-path NLSPATH              $prefix/locale"  >> $module_file
    fi

    if [ -d "$prefix/share/man" ]
    then
        echo "prepend-path MANPATH              $prefix/share/man" >> $module_file
    fi

    if [ -d "$prefix/share/info" ]
    then
        echo "prepend-path INFOPATH             $prefix/share/info" >> $module_file
    fi

    if [ -d "$prefix/share/locale" ]
    then
        echo "prepend-path NLSPATH              $prefix/share/locale" >> $module_file
    fi

    echo ""                                                         >> $module_file
    bldr_pop_dir

    bldr_report "Linking module '$pkg_name/$pkg_vers' as '$pkg_name/latest' ..."
    bldr_output_hline
    if [ -e "$module_dir/latest" ]
    then
        bldr_remove_file "$module_dir/latest"
    fi
    ln -sv "$module_dir/$pkg_vers" "$module_dir/latest"
    bldr_output_hline    

}

####################################################################################################

function bldr_build_pkg()
{
    local pkg_ctry=""
    local pkg_name="" 
    local pkg_vers=""
    local pkg_info=""
    local pkg_desc=""
    local pkg_file=""
    local pkg_urls=""
    local pkg_reqs=""
    local pkg_opts=""
    local pkg_cflags=""
    local pkg_ldflags=""
    local pkg_cfg=""

    while true ; do
        case "$1" in
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
           --requires)      pkg_reqs="$pkg_reqs:$2"; shift 2;;
           --url)           pkg_urls="$pkg_urls;$2"; shift 2;;
           * )              break ;;
        esac
    done

    if [ "$pkg_name" == "" ] || [ "$pkg_vers" == "" ] || [ "$pkg_file" == "" ]
    then
        bldr_bail "Incomplete package definition!  Need at least 'name', 'version' and 'file' defined!"
    fi

    local existing=$(bldr_has_pkg --category "$pkg_ctry" --name "$pkg_name" --version "$pkg_vers" --options "$pkg_opts")

    if [ "$existing" != "false" ]
    then
        bldr_output_hline
        bldr_report "Skipping existing package '$pkg_name/$pkg_vers' ... "
        bldr_output_hline
        return
    fi

    if [ $BLDR_VERBOSE != false ]
    then
        bldr_output_hline
        echo "PkgCategory:  '$pkg_ctry'"
        echo "PkgName:      '$pkg_name'"
        echo "PkgVersion:   '$pkg_vers'"
        echo "PkgInfo:      '$pkg_info'"
        echo "PkgFile:      '$pkg_file'"
        echo "PkgUrls:      '$pkg_urls'"
        echo "PkgOpts:      '$pkg_opts'"
        echo "PkgReqs:      '$pkg_reqs'"
        echo "PkgCFlags:    '$pkg_cflags'"
        echo "PkgLDFlags:   '$pkg_ldflags'"
        echo "PkgCFG:       '$pkg_cfg'"
        echo "PkgDesc:      "
        echo " "
        echo "$pkg_desc"
        echo " "
    fi

    local override_setup=$(type -t bldr_pkg_setup_method)
    local override_fetch=$(type -t bldr_pkg_fetch_method)
    local override_boot=$(type -t bldr_pkg_boot_method)
    local override_config=$(type -t bldr_pkg_config_method)
    local override_compile=$(type -t bldr_pkg_compile_method)
    local override_install=$(type -t bldr_pkg_install_method)
    local override_migrate=$(type -t bldr_pkg_migrate_method)
    local override_modulate=$(type -t bldr_pkg_modulate_method)

    # Call the overridden package methods for each build phase if they were defined
    # -- otherwise use the default internal ones (which should handle 90% of most packages)
    if [  "$override_setup" == "function" ]
    then
        bldr_pkg_setup_method     --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    else
        bldr_setup_pkg            --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    fi

    if [ "$override_fetch" == "function" ]
    then
        bldr_pkg_fetch_method     --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    else
        bldr_fetch_pkg            --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    fi

    if [ "$override_boot" == "function" ]
    then
        bldr_pkg_boot_method      --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    else
        bldr_boot_pkg             --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    fi

    if [ "$override_config" == "function" ]
    then
        bldr_pkg_config_method    --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    else
        bldr_config_pkg           --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    fi

    if [ "$override_compile" == "function" ]
    then
        bldr_pkg_compile_method   --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"

        bldr_compile_pkg          --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    fi

    if [ "$override_install" == "function" ]
    then
        bldr_pkg_install_method   --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    else
        bldr_install_pkg          --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    fi

    if [ "$override_migrate" == "function" ]
    then
        bldr_pkg_migrate_method   --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    else
        bldr_migrate_pkg          --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    fi

    if [ "$override_modulate" == "function" ]
    then
        bldr_pkg_modulate_method  --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"
    else
        bldr_modulate_pkg         --category    "$pkg_ctry"    \
                                  --name        "$pkg_name"    \
                                  --version     "$pkg_vers"    \
                                  --info        "$pkg_info"    \
                                  --description "$pkg_desc"    \
                                  --file        "$pkg_file"    \
                                  --url         "$pkg_urls"    \
                                  --requires    "$pkg_reqs"    \
                                  --options     "$pkg_opts"    \
                                  --cflags      "$pkg_cflags"  \
                                  --ldflags     "$pkg_ldflags" \
                                  --config      "$pkg_cfg"

    fi

    bldr_report "DONE building '$pkg_name/$pkg_vers'! --"
    bldr_output_hline
}

####################################################################################################

function bldr_build_pkgs()
{
    local pkg_names="${1}"
    local pkg_list=$(echo $pkg_names | bldr_split_str ":" | bldr_join_str " ")
    local pkg_dir="$BLDR_PKGS_DIR"

    if [ ! "$pkg_list" ]
    then
        pkg_list="*"
    fi

    if [[ -d $pkg_dir ]]
    then
        local builder
        bldr_output_hline
        bldr_report "Starting build for '$pkg_list' in '$pkg_dir'..."
        bldr_output_hline
        for pkg_category in $pkg_list
        do
            for pkg_def in "$pkg_dir/$pkg_category"/*
            do
                if [[ -x $pkg_def ]]
                then
                    bldr_report "Starting build for '$pkg_def'..."
                    eval $pkg_def || exit -1
                fi
            done
        done
    fi
}

####################################################################################################

