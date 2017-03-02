#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="text"
pkg_name="itstool"

pkg_default="2.0.2"
pkg_variants=("2.0.2")

pkg_info="TS Tool allows you to translate your XML documents with PO files, using rules from the W3C Internationalization Tag Set (ITS) to determine what to translate and how to separate it into PO file messages."

pkg_desc="TS Tool allows you to translate your XML documents with PO files, using rules from the W3C Internationalization Tag Set (ITS) to determine what to translate and how to separate it into PO file messages.

PO files are the standard translation format for GNU and other Unix-like systems. They present translatable information as discrete messages, allowing each message to be translated independently. In contrast to whole-page translation, translating with a message-based format like PO means you can easily track changes to the source document down to the paragraph. When new strings are added or existing strings are modified, you only need to update the corresponding messages.

ITS Tool is designed to make XML documents translatable through PO files by applying standard ITS rules, as well as extension rules specific to ITS Tool. ITS also provides an industry standard way for authors to override translation information in their documents, such as whether a particular element should be translated.

Colophon: ITS Tool is free and open source software under the GPL 3. You can modify it and redistribute it all you want, provided all changes are under the GPL. The ITS files that ship with ITS Tool may be modified and redistributed without restriction. ITS Tool is developed primarily by Shaun McCance. Email Shaun at shaunm@gnome.org."

pkg_opts="configure "
pkg_uses="python"
pkg_reqs="python"
pkg_cflags=""
pkg_ldflags=""
pkg_cfg=""

####################################################################################################
# register each pkg version with bldr
####################################################################################################

for pkg_vers in ${pkg_variants[@]}
do
     pkg_file="$pkg_name-$pkg_vers.tar.bz2"
     pkg_urls="http://files.itstool.org/$pkg_name/$pkg_file"

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
done

####################################################################################################
