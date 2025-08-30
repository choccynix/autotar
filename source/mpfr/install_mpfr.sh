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
tar -xvf "$LATEST

cd $STAGE

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2

$MAKE

$MAKE html

$MAKE install

$MAKE install-html
