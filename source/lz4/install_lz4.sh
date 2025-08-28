#!/bin/bash

set -e

rm -rf lz4-*

URL=$(curl -s https://api.github.com/repos/lz4/lz4/releases/latest \
  | grep "browser_download_url" \
  | cut -d '"' -f 4 \
  | grep '\.tar\.gz$')

STAGE=$(basename "$URL" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

# 64 bit

make BUILD_STATIC=no PREFIX=/usr -j$(nproc)

make DESTDIR=/tmp/choccynix BUILD_STATIC=no PREFIX=/usr install

# 32 bit 

make clean

CC="gcc -m32" make BUILD_STATIC=no

make BUILD_STATIC=no PREFIX=/usr LIBDIR=/usr/lib32 DESTDIR=$(pwd)/m32 install &&
cp -a m32/usr/lib32/* /tmp/choccynix/usr/lib32/

# x32 bit

make clean

CC="gcc -mx32" make BUILD_STATIC=no

make BUILD_STATIC=no PREFIX=/usr LIBDIR=/usr/libx32 DESTDIR=$(pwd)/mx32 install &&
cp -a mx32/usr/libx32/* /tmp/choccynix/usr/libx32/





