#!/bin/bash

set -e

rm -rf zlib-*

URL="https://zlib.net/fossils/"

LATEST=$(curl -s $URL \
  | grep -oP 'zlib-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

# 64 bit

./configure --prefix=/usr

make -j$(nproc)

make DESTDIR=/tmp/choccynix install

# 32 bit

make distclean

CFLAGS+=" -m32" CXXFLAGS+=" -m32" \
./configure --prefix=/usr \
    --libdir=/usr/lib32

make -j$(nproc)

make DESTDIR=/tmp/choccynix/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /tmp/choccynix/usr/lib32
rm -rf DESTDIR

# -x32 bit

make distclean

CFLAGS+=" -mx32" CXXFLAGS+=" -mx32" \
./configure --prefix=/usr    \
    --libdir=/usr/libx32

make -j$(nproc)

make DESTDIR=/tmp/choccynix/DESTDIR install
cp -Rv DESTDIR/usr/libx32/* /tmp/choccynix/usr/libx32
rm -rf DESTDIR/

