#!/bin/bash

set -e 

URL="https://ftp.gnu.org/gnu/mpc/"

rm -rf mpc-*

LATEST=$(curl -s $URL \
  | grep -oP 'mpc-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-$(date)

$MAKE

$MAKE html

$MAKE install

$MAKE install-html
