#!/bin/bash

set -e

rm -rf binutils-*

URL="https://sourceware.org/pub/bzip2/"

LATEST=$(curl -s "$URL" \
  | grep -o 'bzip2-[0-9]\+\.[0-9]\+\(\.[0-9]\+\)\?\.tar\.gz' \
  | sort -V \
  | uniq \
  | tail -n1)

if [ -z "$LATEST" ]; then
  echo "Falling back to bzip2-latest.tar.gz"
  LATEST="bzip2-latest.tar.gz"
fi

curl -fL -o "$LATEST" "${URL}${LATEST}"

STAGE=$(basename "$LATEST" .tar.gz)
tar -xvzf "$LATEST" 
cd $STAGE
#patch -Np1 -i ../patches/*.patch # will try without a patch in the meantime

# 64 bit

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make clean
make -f Makefile-libbz2_so CFLAGS="-fPIC"
make clean
make CFLAGS="-fPIC" -j$(nproc)

make -n install PREFIX=/tmp/choccynix/usr

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


