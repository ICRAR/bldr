#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="text"
pkg_name="gettext"
pkg_vers="0.18.1.1"
pkg_info="GNU gettext is designed to minimize the impact of internationalization on program sources."

pkg_desc="GNU gettext is designed to minimize the impact of internationalization on program sources, 
keeping this impact as small and hardly noticeable as possible. Internationalization has better 
chances of succeeding if it is very light weighted, or at least, appear to be so, when looking at 
program sources.

The Translation Project also uses the GNU gettext distribution as a vehicle for documenting its 
structure and methods. This goes beyond the strict technicalities of documenting the GNU gettext 
proper. By so doing, translators will find in a single place, as far as possible, all they need 
to know for properly doing their translating work. Also, this supplemental documentation might 
also help programmers, and even curious users, in understanding how GNU gettext is related to the 
remainder of the Translation Project, and consequently, have a glimpse at the big picture."

pkg_file="$pkg_name-$pkg_vers.tar.gz"
pkg_urls="http://ftp.gnu.org/pub/gnu/gettext/$pkg_file"
pkg_opts="configure"
pkg_reqs="$pkg_reqs coreutils/latest"
pkg_reqs="$pkg_reqs zlib/latest"
pkg_reqs="$pkg_reqs libicu/latest"
pkg_reqs="$pkg_reqs libunistring/latest"
pkg_reqs="$pkg_reqs expat/latest"
pkg_reqs="$pkg_reqs libxml2/latest"
pkg_reqs="$pkg_reqs libiconv/latest"
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

pkg_cfg="--with-gnu-ld --without-emacs --disable-rpath"
pkg_cfg="$pkg_cfg --with-included-libunistring"
pkg_cfg="$pkg_cfg --with-included-libcroco"
pkg_cfg="$pkg_cfg --with-libunistring-prefix=\"$BLDR_LIBUNISTRING_BASE_PATH\""
pkg_cfg="$pkg_cfg --with-libexpat-prefix=\"$BLDR_EXPAT_BASE_PATH\""
pkg_cfg="$pkg_cfg --with-libxml2-prefix=\"$BLDR_LIBXML2_BASE_PATH\""
pkg_cfg="$pkg_cfg --with-libiconv-prefix=\"$BLDR_LIBICONV_BASE_PATH\""
pkg_patch=""
pkg_cflags=""
pkg_ldflags=""

if [[ $BLDR_SYSTEM_IS_LINUX == true ]]
then
     pkg_cflags="$pkg_cflags -fPIC"
fi

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
               --patch       "$pkg_patch"   \
               --uses        "$pkg_uses"    \
               --requires    "$pkg_reqs"    \
               --options     "$pkg_opts"    \
               --cflags      "$pkg_cflags"  \
               --ldflags     "$pkg_ldflags" \
               --config      "$pkg_cfg"


