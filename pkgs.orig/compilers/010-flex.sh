#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="compilers"
pkg_name="flex"

pkg_default="2.5.36"
pkg_variants=("2.5.36")

pkg_info="Flex is a tool for generating scanners (eg for building custom compilers)."

pkg_desc="Flex is a tool for generating scanners. A scanner, sometimes called a 
tokenizer, is a program which recognizes lexical patterns in text. The flex 
program reads user-specified input files, or its standard input if no file 
names are given, for a description of a scanner to generate. The description 
is in the form of pairs of regular expressions and C code, called rules. Flex 
generates a C source file named, lex.yy.c, which defines the function yylex(). 
The file lex.yy.c can be compiled and linked to produce an executable. When 
the executable is run, it analyzes its input for occurrences of text matching 
the regular expressions for each rule. Whenever it finds a match, it executes 
the corresponding C code."

pkg_opts="configure enable-static enable-shared"
pkg_reqs=""
pkg_uses=""

pkg_cflags=""
pkg_ldflags=""
pkg_cfg="" 

####################################################################################################
# register each pkg version with bldr
####################################################################################################

for pkg_vers in ${pkg_variants[@]}
do
     pkg_file="$pkg_name-$pkg_vers.tar.bz2"
     pkg_urls="http://prdownloads.sourceforge.net/$pkg_name/$pkg_file?download"

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

