#!/bin/bash

set -e

rm -rf binutils-*

URL="https://ftp.gnu.org/gnu/gcc/"

LATEST=$(curl -s $URL \
  | grep -oP 'gcc-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64

sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h

mkdir -v build
cd       build

mlist=m64,m32
../configure --prefix=/usr               \
             LD=ld                       \
             --enable-languages=c,c++    \
             --enable-default-pie        \
             --enable-default-ssp        \
             --enable-host-pie           \
             --enable-multilib           \
             --with-multilib-list=$mlist \
             --disable-bootstrap         \
             --disable-fixincludes       \
             --with-system-zlib

$MAKE

sed -e '/cpython/d' -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp

$MAKE install

ln -svr $LFS/usr/bin/cpp $LFS/usr/lib

ln -sv gcc.1 $LFS/usr/share/man/man1/cc.1

ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/15.2.0/liblto_plugin.so \
        $LFS/usr/lib/bfd-plugins/

mkdir -pv $LFS/usr/share/gdb/auto-load/usr/lib
mv -v $LFS/usr/lib/*gdb.py $LFS/usr/share/gdb/auto-load/usr/lib

