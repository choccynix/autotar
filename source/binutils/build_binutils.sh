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

../configure \
    --prefix=/usr           \
    --libdir=/usr/lib       \
    --enable-shared         \
    --disable-multilib      \
    --disable-nls           \
    --disable-werror

make -j$(nproc)

$MAKE install
