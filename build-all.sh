#!/bin/sh

# GNU Toolchain for nano-cpu32k architecture
# Copyright (C) 2019 cassuto <diyer175@hotmail.com>
#
# Required packages to run this script: wget, md5sum, tar
#
# This program is free software# you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation# either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY# without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program# if not, see <http://www.gnu.org/licenses/>

cache_dir="./cache"
binutils_version="2.32"
binutils_checksum="0d174cdaf85721c5723bf52355be41e6"
binutils_filename="binutils-$binutils_version.tar.xz"
binutils_patach_filename="ncpu32k-binutils-2.32.patch"
url_binutils="http://ftp.gnu.org/gnu/binutils/$binutils_filename"

if [ ! -d "$cache_dir" ]; then
    mkdir "$cache_dir"
fi

if [ ! -f "$cache_dir/$binutils_filename" ]; then
    if [ -f "./$binutils_filename" ]; then
        echo "Found $binutils_filename from source tree!"
        mv "./$binutils_filename" "$cache_dir/$binutils_filename"
    else
        echo "Start to fetch binutils-$binutils_version from repo..."
        wget "$url_binutils" -O "$cache_dir/$binutils_filename"
        if [ $? != 0 ]; then
            echo "Error: Failed to access the remote!"
            exit 1
        fi
    fi
fi

checksum_md5=`md5sum -b "$cache_dir/$binutils_filename" | awk '{print $1}'`
echo "MD5 Checksum of '$cache_dir/$binutils_filename' = $checksum_md5"
if [ $? != 0 -o "$checksum_md5"x != "$binutils_checksum"x ]; then
    echo "Error: Failed to verify file '$cache_dir/$binutils_filename', which means target file has been broken. Delete it and Try again!"
    exit 1
fi

echo "Unpacking '$cache_dir/$binutils_filename'..."
tar -xvf "$cache_dir/$binutils_filename" -C "./"
if [ $? != 0 -o ! -d "./binutils-$binutils_version" ]; then
    echo "Error: Failed to unpack file!"
    exit 1
fi

echo "Applying patches for binutils-$binutils_version ..."
patch -p1 -d "./binutils-$binutils_version" < "$binutils_patach_filename"
if [ $? != 0 ]; then
    echo "Error: Failed to apply patch!"
    exit 1
fi

echo "Succeeded to bootstrap source tree!"

