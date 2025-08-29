#!/bin/bash

set -e 

rm -rf ztsd-*

URL=$(curl -s https://api.github.com/facebook/zstd/releases/latest \
  | grep "browser_download_url" \
  | cut -d '"' -f 4 \
  | grep '\.tar\.gz$')

STAGE=$(basename "$URL" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

# 64 bit

make prefix=/usr

make DISTDIR=/tmp/choccynix prefix=/usr install

rm -v /tmp/choccynix/usr/lib/libzstd.a

# 32 bit

make clean

CC="gcc -m32" make prefix=/usr

make prefix=/usr DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib/* /tmp/choccynix/usr/lib32/
sed -e "/^libdir/s/lib$/lib32/" -i /tmp/choccynix/usr/lib32/pkgconfig/libzstd.pc
rm -rf DESTDIR

# x32 bit 

make clean

CC="gcc -mx32" make prefix=/usr

make prefix=/usr DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib/* /usr/libx32/
sed -e "/^libdir/s/lib$/libx32/" -i /tmp/choccynix/usr/libx32/pkgconfig/libzstd.pc
rm -rf DESTDIR
