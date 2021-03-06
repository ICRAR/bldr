#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="compression"
pkg_name="7zip"

pkg_default="9.20"
pkg_variants=("9.20")
pkg_distribs=("7z920.tar.bz2")
pkg_mirrors=("http://downloads.sourceforge.net/sevenzip/7z920.tar.bz2")

pkg_info="7-Zip is a file archiver with a high compression ratio."

pkg_desc="7-Zip is a file archiver with a high compression ratio.

The main features of 7-Zip

* High compression ratio in 7z format with LZMA and LZMA2 compression
* Supported formats:
-- Packing / unpacking: 7z, XZ, BZIP2, GZIP, TAR, ZIP and WIM
-- Unpacking only: ARJ, CAB, CHM, CPIO, CramFS, DEB, DMG, FAT, HFS, ISO, LZH, LZMA, MBR, MSI, NSIS, NTFS, RAR, RPM, SquashFS, UDF, VHD, WIM, XAR and Z.

* For ZIP and GZIP formats, 7-Zip provides a compression ratio that is 2-10 % better than the ratio provided by PKZip and WinZip
* Strong AES-256 encryption in 7z and ZIP formats
* Self-extracting capability for 7z format
* Integration with Windows Shell
* Powerful File Manager
* Powerful command line version
* Plugin for FAR Manager
* Localizations for 79 languages

7-Zip is open source software. Most of the source code is under the GNU LGPL license. 

The unRAR code is under a mixed license: GNU LGPL + unRAR restrictions. 

You can use 7-Zip on any computer, including a computer in a commercial organization. 
You don't need to register or pay for 7-Zip."


pkg_opts="configure "
pkg_opts+="enable-static "
pkg_opts+="enable-shared" 

pkg_uses=""
pkg_reqs=""

pkg_cflags=""
pkg_ldflags=""

pkg_cfg=""
pkg_cfg_path=""

####################################################################################################
# register each pkg version with bldr
####################################################################################################

let pkg_idx=0
for pkg_vers in ${pkg_variants[@]}
do
    pkg_file=${pkg_distribs[$pkg_idx]}
    pkg_urls=${pkg_mirrors[$pkg_idx]}

    bldr_register_pkg                \
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

    let pkg_idx++
done

####################################################################################################
