#!/bin/bash

set -a

rm -rf binutils-*

URL="https://distfiles.ariadne.space/pkgconf/"

LATEST=$(curl -s $URL \
  | grep -oP 'pkgconf-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/pkgconf-2.5.1

$MAKE

$MAKE install

ln -sv pkgconf   $LFS/usr/bin/pkg-config
ln -sv pkgconf.1 $LFS/usr/share/man/man1/pkg-config.1


