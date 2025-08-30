#!/bin/bash

set -e

rm -rf binutils-*

URL="ftp.gnu.org/gnu/gmp/"

LATEST=$(curl -s $URL \
  | grep -oP 'gmp-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

sed -i '/long long t1;/,+1s/()/(...)/' configure

# 64 bit

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

$MAKE

$MAKE html

# 32 bit

make distclean

cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub

ABI="32" \
CFLAGS="-m32 -O2 -pedantic -fomit-frame-pointer -mtune=generic -march=i686" \
CXXFLAGS="$CFLAGS" \
PKG_CONFIG_PATH="/usr/lib32/pkgconfig" \
./configure                      \
    --host=i686-pc-linux-gnu     \
    --prefix=/usr                \
    --disable-static             \
    --enable-cxx                 \
    --libdir=/usr/lib32          \
    --includedir=/usr/include/m32/gmp

sed -i 's/$(exec_prefix)\/include/$\(includedir\)/' Makefile
$MAKE

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $LFS/usr/lib32
cp -Rv DESTDIR/usr/include/m32/* $LFS/usr/include/m32/
rm -rf DESTDIR

# x32 bit

make distclean

cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub

ABI="x32" \
CFLAGS="-mx32 -O2 -pedantic -fomit-frame-pointer -mtune=generic -march=x86-64" \
CXXFLAGS="$CFLAGS" \
PKG_CONFIG_PATH="/usr/libx32/pkgconfig" \
./configure                       \
    --host=x86_64-pc-linux-gnux32 \
    --prefix=/usr                 \
    --disable-static              \
    --enable-cxx                  \
    --libdir=/usr/libx32          \
    --includedir=/usr/include/mx32/gmp

sed -i 's/$(exec_prefix)\/include/$\(includedir\)/' Makefile
$MAKE

make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/libx32/* $LFS/usr/libx32
cp -Rv DESTDIR/usr/include/mx32/* $LFS/usr/include/mx32/
rm -rf DESTDIR




