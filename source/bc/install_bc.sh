#!/bin/bash

set -e

rm -rf bc-*

URL=$(curl -s https://api.github.com/repos/gavinhoward/bc/releases/latest \
  | grep "browser_download_url" \
  | cut -d '"' -f 4 \
  | grep '\.tar\.gz$')

curl -LO "$URL"

TARBALL=$(basename "$URL")
STAGE=$(basename "$TARBALL" .tar.gz)
tar -xvf "$TARBALL"

cd $STAGE

CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r

make

make DESTDIR=/tmp/choccynix install




