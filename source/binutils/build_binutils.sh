#!/bin/bash

set -e

rm -rf binutils-*

URL="https://sourceware.org/pub/binutils/releases/"

LATEST=$(curl -s $URL \
  | grep -oP 'binutils-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE
mkdir build
cd build

../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

make tooldir=/usr

$MAKE tooldir=/usr install

rm -rfv $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        $LFS/usr/share/doc/gprofng/
