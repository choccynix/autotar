#!/bin/bash

set -a 

rm -rf dejagnu-*

URL="https://ftp.gnu.org/gnu/dejagnu/"

LATEST=$(curl -s $URL \
  | grep -oP 'dejagnu-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

mkdir -v build
cd       build

../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

$MAKE install

install -v -dm755  $LFS/usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} $LFS/usr/share/doc/dejagnu-1.6.3
