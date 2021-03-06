#!/bin/bash

####################################################################################################
# import the BLDR system
####################################################################################################

source "bldr.sh"

####################################################################################################
# setup pkg definition and resource files
####################################################################################################

pkg_ctry="system"
pkg_name="libevent"

pkg_default="2.0.20"
pkg_variants=("2.0.20")

pkg_info="Libevent provides a sophisticated framework for buffered network IO, with support for sockets, filters, rate-limiting, SSL, zero-copy file transmission, and IOCP."

pkg_desc="The libevent API provides a mechanism to execute a callback function when 
a specific event occurs on a file descriptor or after a timeout has been reached. 
Furthermore, libevent also support callbacks due to signals or regular timeouts.
libevent is meant to replace the event loop found in event driven network servers. 
An application just needs to call event_dispatch() and then add or remove events 
dynamically without having to change the event loop.

Currently, libevent supports /dev/poll, kqueue(2), event ports, POSIX select(2), 
Windows select(), poll(2), and epoll(4). The internal event mechanism is completely 
independent of the exposed event API, and a simple update of libevent can provide 
new functionality without having to redesign the applications. As a result, Libevent 
allows for portable application development and provides the most scalable event 
notification mechanism available on an operating system. Libevent can also be used 
for multi-threaded applications, either by isolating each event_base so that only 
a single thread accesses it, or by locked access to a single shared event_base. 
Libevent should compile on Linux, *BSD, Mac OS X, Solaris, Windows, and more."

pkg_opts="configure "
pkg_opts+="enable-static "
pkg_opts+="enable-shared "

pkg_uses=""
pkg_reqs=""
pkg_cflags=""
pkg_ldflags=""
pkg_cfg=""

####################################################################################################
# register each pkg version with bldr
####################################################################################################

for pkg_vers in ${pkg_variants[@]}
do
     pkg_file="$pkg_name-$pkg_vers-stable.tar.gz"
     pkg_urls="http://github.com/downloads/libevent/libevent/$pkg_file"

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
