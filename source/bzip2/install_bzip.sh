#!/bin/bash

set -e

rm -rf binutils-*

URL="https://www.sourceware.org/pub/bzip2/"

LATEST=$(curl -s $URL \
  | grep -oP 'bzip2-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE
patch -Np1 -i ../patches/*.patch

# 64 bit

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make -f Makefile-libbz2_so
make clean

make -j$(nproc)

make DESTDIR=/tmp/choccynix PREFIX=/usr install

# 32 bit

make clean

sed -e "s/^CC=.*/CC=gcc -m32/" -i Makefile{,-libbz2_so}
make -f Makefile-libbz2_so
make libbz2.a -j$(nproc)

install -Dm755 libbz2.so.1.0.8 /tmp/choccynix/usr/lib32/libbz2.so.1.0.8
ln -sf libbz2.so.1.0.8 /tmp/choccynix/usr/lib32/libbz2.so
ln -sf libbz2.so.1.0.8 /tmp/choccynix/usr/lib32/libbz2.so.1
ln -sf libbz2.so.1.0.8 /tmp/choccynix/usr/lib32/libbz2.so.1.0
install -Dm644 libbz2.a /tmp/choccynix/usr/lib32/libbz2.a

# x32 bit

make clean

sed -e "s/^CC=.*/CC=gcc -mx32/" -i Makefile{,-libbz2_so}
make -f Makefile-libbz2_so
make libbz2.a

install -Dm755 libbz2.so.1.0.8 /tmp/choccynix/usr/libx32/libbz2.so.1.0.8
ln -sf libbz2.so.1.0.8 /tmp/choccynix/usr/libx32/libbz2.so
ln -sf libbz2.so.1.0.8 /tmp/choccynix/usr/libx32/libbz2.so.1
ln -sf libbz2.so.1.0.8 /tmp/choccynix/usr/libx32/libbz2.so.1.0
install -Dm644 libbz2.a /tmp/choccynix/usr/libx32/libbz2.a


