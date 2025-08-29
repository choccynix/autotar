#!/bin/bash

set -e 

rm -rf m4-*

URL="https://ftp.gnu.org/gnu/m4/"

LATEST=$(curl -s $URL \
  | grep -oP 'm4-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"

cd "$LATEST"

sed 's/\[\[__nodiscard__]]//' -i lib/config.hin

sed 's/test-stdalign\$(EXEEXT) //' -i tests/Makefile.in

./configure --prefix=/usr

make DISTDIR=/tmp/choccynix install
