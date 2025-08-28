#!/bin/bash

set -e

rm -rf manpages-*

URL="https://www.kernel.org/pub/linux/docs/man-pages/

LATEST=$(curl -s $URL \
  | grep -oP 'man-pages-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

rm -v man3/crypt*
make -R DESTDIR=/tmp/choccynix GIT=false prefix=/usr install

