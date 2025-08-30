#!/bin/bash

set -e

rm -rf expect-*

URL="https://prdownloads.sourceforge.net/expect/"

LATEST=$(curl -s $URL \
  | grep -oP 'expect-\d+\.\d+(\.\d+)?\.tar\.gz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.gz)
tar -xvf "$LATEST"

cd $STAGE 

wget "https://www.linuxfromscratch.org/patches/lfs/development/expect-5.45.4-gcc15-1.patch" # might change when it breaks lmfao

patch -Np1 -i expect-5.45.4-gcc15-1.patch

./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

$MAKE install

ln -svf expect5.45.4/libexpect5.45.4.so $LFS/usr/lib




