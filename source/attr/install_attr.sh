#!/bin/bash

set -e 

rm -rf attr-*

URL="https://download.savannah.gnu.org/releases/attr/"

LATEST=$(curl -s $URL \
  | grep -oP 'attr-\d+\.\d+(\.\d+)?\.tar\.gz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

# 64 bit

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

$MAKE

$MAKE install

# 32 bit

make distclean

CC="gcc -m32" ./configure \
    --prefix=/usr         \
    --disable-static      \
    --sysconfdir=/etc     \
    --libdir=/usr/lib32   \
    --host=i686-pc-linux-gnu

$MAKE

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $LFS/usr/lib32
rm -rf DESTDIR

# x32 bit

# no x32 bit in the multilib dox?


