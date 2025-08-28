#!/bin/bash

set -e

rm -rf glibc-*

URL="https://ftp.gnu.org/gnu/glibc/"

LATEST=$(curl -s $URL \
  | grep -oP 'glibc-\d+\.\d+(\.\d+)?\.tar\.xz' \
  | sort -V \
  | tail -n1)

curl -L "${URL}${LATEST}" -o "$LATEST"
STAGE=$(basename "$LATEST" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE
patch -Np1 -i ../patches/glibc-2.42-fhs-1.patch

# added shit from the LFS multilib book found here - https://www.linuxfromscratch.org/~thomas/multilib/chapter08/glibc.html

sed -e '/unistd.h/i #include <string.h>' \
    -e '/libc_rwlock_init/c\
  __libc_rwlock_define_initialized (, reset_lock);\
  memcpy (&lock, &reset_lock, sizeof (lock));' \
    -i stdlib/abort.c

mkdir -v build
cd       build

echo "rootsbindir=/tmp/choccynix/usr/sbin" > configparms

../configure --prefix=/usr                   \
             --disable-werror                \
             --disable-nscd                  \
             libc_cv_slibdir=/usr/lib        \
             --enable-stack-protector=strong \
             --enable-kernel=5.4

make -j$(nproc)

touch /mnt/choccynix/etc/ld.so.conf

sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

make DESTDIR=/tmp/choccynix install 

sed '/RTLDLIST=/s@/usr@@g' -i /tmp/choccynix/usr/bin/ldd

make DESTDIR=/tmp/choccynix localedata/install-locales

cat > /tmp/choccynix/etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

cat > /tmp/choccynix/etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /tmp/choccynix/etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /tmp/choccynix/etc/ld.so.conf.d

rm -rf ./*

find .. -name "*.a" -delete

CC="gcc -m32" CXX="g++ -m32" \
../configure                             \
      --prefix=/usr                      \
      --host=i686-pc-linux-gnu           \
      --build=$(../scripts/config.guess) \
      --libdir=/usr/lib32                \
      --libexecdir=/usr/lib32            \
      --disable-werror                   \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib32         \
      --enable-stack-protector=strong    \
      --enable-kernel=5.4

make -j$(nproc)

make DESTDIR=/tmp/choccynix/DESTDIR install
cp -a DESTDIR/usr/lib32/* /tmp/choccy/usr/lib32/
install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
               /tmp/choccy/usr/include/gnu/

echo "/usr/lib32" >> /tmp/choccynix/etc/ld.so.conf

rm -rf ./*
find .. -name "*.a" -delete

CC="gcc -mx32" CXX="g++ -mx32" \
../configure                             \
      --prefix=/usr                      \
      --host=x86_64-pc-linux-gnux32      \
      --build=$(../scripts/config.guess) \
      --libdir=/usr/libx32               \
      --libexecdir=/usr/libx32           \
      --disable-werror                   \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/libx32        \
      --enable-stack-protector=strong    \
      --enable-kernel=5.4

make -j$(nproc)
make DESTDIR=/tmp/choccynix/DESTDIR install
cp -a DESTDIR/usr/libx32/* /tmp/choccynix/usr/libx32/
install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-x32.h \
               /tmp/choccynix/usr/include/gnu/

echo "/usr/libx32" >> /tmp/choccynix/etc/ld.so.conf


