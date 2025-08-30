#!/bin/bash

set -e

rm -rf acl-*

URL="https://download.savannah.gnu.org/releases/acl/"

LATEST=$(curl -s $URL \
  | grep -oP 'binutils-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

# 64

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/acl-$(date)

$MAKE

$MAKE install

# 32

make distclean

CC="gcc -m32" ./configure \
    --prefix=/usr         \
    --disable-static      \
    --libdir=/usr/lib32   \
    --libexecdir=/usr/lib32   \
    --host=i686-pc-linux-gnu

$MAKE

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $LFS/usr/lib32
rm -rf DESTDIR
