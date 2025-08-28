#!/bin/bash

set -e

rm -rf xz-*

URL=$(curl -s https://api.github.com/repos/tukaani-project/xz/releases/latest \
  | grep "browser_download_url" \
  | cut -d '"' -f 4 \
  | grep '\.tar\.gz$')

STAGE=$(basename "$URL" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

# 64 bit

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.8.1

make -j$(nproc)

make DESTDIR=/tmp/choccynix install 

# 32 bit 

make distclean

CC="gcc -m32" ./configure \
    --host=i686-pc-linux-gnu      \
    --prefix=/usr                 \
    --libdir=/usr/lib32           \
    --disable-static

make -j$(nproc)

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /tmp/choccynix/usr/lib32
rm -rf DESTDIR

# x32 bit

make distclean

CC="gcc -mx32" ./configure \
    --host=x86_64-pc-linux-gnux32 \
    --prefix=/usr                 \
    --libdir=/usr/libx32          \
    --disable-static

make -j$(nproc)

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/libx32/* /tmp/choccynix/usr/libx32
rm -rf DESTDIR

