#!/bin/bash

set -e 

rm -rf isl-*

URL="https://libisl.sourceforge.io/"

LATEST=$(curl -s $URL \
  | grep -oP 'isl-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/isl-0.27

$MAKE

$MAKE install

install -vd $LFS/usr/share/doc/isl-0.27
install -m644 doc/{CodingStyle,manual.pdf,SubmittingPatches,user.pod} \
        $LFS/usr/share/doc/isl-0.27


