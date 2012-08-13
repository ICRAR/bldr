#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="text"
pkg_name="libiconv"
pkg_vers="1.14"

pkg_info="The GNU libiconv library provides utilities for converting text from/to Unicode via the iconv() method."

pkg_desc="The GNU libiconv library provides utilities for converting text from/to Unicode via the iconv() method.

For historical reasons, international text is often encoded using a language or country dependent 
character encoding. With the advent of the internet and the frequent exchange of text across 
countries - even the viewing of a web page from a foreign country is a 'text exchange' in this 
context -, conversions between these encodings have become important. They have also become a problem, 
because many characters which are present in one encoding are absent in many other encodings. To 
solve this mess, the Unicode encoding has been created. It is a super-encoding of all others and 
is therefore the default encoding for new text formats like XML.

Still, many computers still operate in locale with a traditional (limited) character encoding. 
Some programs, like mailers and web browsers, must be able to convert between a given text encoding 
and the user's encoding. Other programs internally store strings in Unicode, to facilitate internal 
processing, and need to convert between internal string representation (Unicode) and external 
string representation (a traditional encoding) when they are doing I/O. GNU libiconv is a 
conversion library for both kinds of applications. "

pkg_file="$pkg_name-$pkg_vers.tar.gz"
pkg_urls="http://ftp.gnu.org/pub/gnu/libiconv/$pkg_file"
pkg_opts="configure"
pkg_reqs="zlib/latest"
pkg_uses="$pkg_reqs"
pkg_cfg="--enable-static --enable-shared"
pkg_cflags=""
pkg_ldflags=""

####################################################################################################
# build and install pkg as local module
####################################################################################################

if [ $BLDR_SYSTEM_IS_OSX == true ]
then
     bldr_log_warning "$pkg_name uses the native OSX version bundled with MacOSX.  Skipping..."
     bldr_log_split
else
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
fi

