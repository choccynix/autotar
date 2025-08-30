#!/bin/bash

set -e

URL="https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/"

LATEST=$(curl -s $URL \
  | grep -oP 'libcap-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd STAGE

# 64 bit

sed -i '/install -m.*STA/d' libcap/Makefile

$MAKE prefix=/usr lib=lib

$MAKE prefix=/usr lib=lib install

# 32 bit

make distclean

$MAKE CC="gcc -m32 -march=i686"

make CC="gcc -m32 -march=i686" lib=lib32 prefix=$PWD/DESTDIR/usr -C libcap install
cp -Rv DESTDIR/usr/lib32/* $LFS/usr/lib32
sed -e "s|^libdir=.*|libdir=/usr/lib32|" -i $LFS/usr/lib32/pkgconfig/lib{cap,psx}.pc
chmod -v 755 $LFS/usr/lib32/libcap.so.2.76
rm -rf DESTDIR

# x32 bit
#
# no x32 bit wtf


