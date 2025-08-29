#!/bin/bash

set -e

rm -rf flex-*

URL=$(curl -s https://api.github.com/repos/westes/flex/releases/latest \
  | grep "browser_download_url" \
  | cut -d '"' -f 4 \
  | grep '\.tar\.gz$')

STAGE=$(tar -tf "$TARBALL" | head -1 | cut -f1 -d"/")

curl -L -o "$STAGE" "$URL"

tar -xvf "$STAGE"

cd $STAGE

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

make

make DISTDIR=/tmp/choccynix install

ln -sv flex   /mnt/choccynix/usr/bin/lex
ln -sv flex.1 /mnt/choccynix/usr/share/man/man1/lex.1




