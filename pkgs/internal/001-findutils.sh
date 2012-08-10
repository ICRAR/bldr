#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="internal"
pkg_name="findutils"
pkg_vers="4.4.2"

pkg_info="GNU Diffutils is a package of several programs related to finding differences between files."

pkg_desc="The GNU Find Utilities are the basic directory searching utilities of the 
GNU operating system. These programs are typically used in conjunction with other 
programs to provide modular and powerful directory search and file locating capabilities 
to other commands.

The tools supplied with this package are:

* find - search for files in a directory hierarchy
* locate - list files in databases that match a pattern
* updatedb - update a file name database
* xargs - build and execute command lines from standard input

The find program searches a directory tree to find a file or group of files. It traverses 
the directory tree and reports all occurrences of a file matching the user's specifications. 
The find program includes very powerful searching capability.

The locate program scans one or more databases of filenames and displays any matches. 
This can be used as a very fast find command if the file was present during the last 
file name database update.

The updatedb program updates the file name database used by the locate program. The 
file name database contains lists of files that were in particular directory trees when 
the databases were last updated. This is usually run nightly by the cron system daemon.

The xargs program builds and executes command lines by gathering together arguments it 
reads on the standard input. Most often, these arguments are lists of file names 
generated by find."

pkg_file="$pkg_name-$pkg_vers.tar.gz"
pkg_urls="http://ftp.gnu.org/gnu/$pkg_name/$pkg_file"
pkg_opts="configure force-static"
pkg_reqs="coreutils/latest"
pkg_uses="$pkg_reqs"
pkg_cflags=""
pkg_ldflags=""
pkg_cfg=""

####################################################################################################
# build and install pkg as local module
####################################################################################################

bldr_build_pkg --category    "$pkg_ctry"     \
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


