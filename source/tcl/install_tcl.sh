#!/bin/bash

set -e 

rm -rf binutils-*

URL="https://downloads.sourceforge.net/tcl/"

LATEST=$(curl -s $URL \
  | grep -oP 'tcl-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd "$LATEST"

SRCDIR=$(pwd)
cd unix

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath

make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.10|/usr/lib/tdbc1.1.10|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10/generic|/usr/include|"     \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10/library|/usr/lib/tcl8.6|"  \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10|/usr/include|"             \
    -i pkgs/tdbc1.1.10/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.2|/usr/lib/itcl4.3.2|" \
    -e "s|$SRCDIR/pkgs/itcl4.3.2/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.3.2|/usr/include|"            \
    -i pkgs/itcl4.3.2/itclConfig.sh

unset SRCDIR

make DISTDIR=/tmp/choccynix install 
chmod 644 /tmp/choccynix/usr/lib/libtclstub8.6.a

chmod -v u+w /tmp/choccynix/usr/lib/libtcl8.6.so

make DISTDIR=/tmp/choccynix install-private-headers

ln -sfv tclsh8.6 /tmp/choccynix/usr/bin/tclsh

mv /tmp/choccynix/usr/share/man/man3/{Thread,Tcl_Thread}.3

