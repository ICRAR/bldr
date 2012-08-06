#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="compilers"
pkg_name="pypy"
pkg_vers="1.9"
pkg_info="PyPy is a fast, compliant alternative implementation of the Python language (2.7.2)."

pkg_desc="PyPy is a fast, compliant alternative implementation of the Python language (2.7.2). 

It has several advantages and distinct features:

- Speed: thanks to its Just-in-Time compiler, Python programs often run faster on PyPy. (What is a JIT compiler?)

- Memory usage: large, memory-hungry Python programs might end up taking less space than they do in CPython.

- Compatibility: PyPy is highly compatible with existing python code. It supports ctypes and can run popular python libraries like twisted and django.

- Sandboxing: PyPy provides the ability to run untrusted code in a fully secure way.

- Stackless: PyPy comes by default with support for stackless mode, providing micro-threads for massive concurrency.

As well as other features."

pkg_file="release-$pkg_vers.tar.bz2"
pkg_urls="http://bitbucket.org/$pkg_name/$pkg_name/get/$pkg_file"
pkg_opts="configure"
pkg_reqs=""
pkg_uses=""
pkg_cflags=""
pkg_ldflags=""
pkg_cfg="" 

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


