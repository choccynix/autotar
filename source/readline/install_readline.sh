#!/bin/bash

set -e

rm -rf readline-*

URL="https://ftp.gnu.org/gnu/readline/"

LATEST=$(curl -s $URL \
  | grep -oP 'readline-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"

cd "$LATEST"

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

# 64 bit

sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.3

make SHLIB_LIBS="-lncursesw"

make DISTDIR=/tmp/choccynix install

# 32 bit

make dist clean

CC="gcc -m32" ./configure \
    --host=i686-pc-linux-gnu      \
    --prefix=/usr                 \
    --libdir=/usr/lib32           \
    --disable-static              \
    --with-curses

make SHLIB_LIBS="-lncursesw"

make SHLIB_LIBS="-lncursesw" DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* /tmp/choccynix/usr/lib32
rm -rf DESTDIR

# x32 bit

make distclean

CC="gcc -mx32" ./configure \
    --host=x86_64-pc-linux-gnux32 \
    --prefix=/usr                 \
    --libdir=/usr/libx32          \
    --disable-static              \
    --with-curses

make SHLIB_LIBS="-lncursesw"

make SHLIB_LIBS="-lncursesw" DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/libx32/* /tmp/choccynix/usr/libx32
rm -rf DESTDIR




