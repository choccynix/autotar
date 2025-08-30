#!/bin/bash

set -e 

rm -rf shadow-*

URL=$(curl -s https://api.github.com/shadow-maint/shadow/releases/latest \
  | grep "browser_download_url" \
  | cut -d '"' -f 4 \
  | grep '\.tar\.gz$')

STAGE=$(basename "$URL" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs

touch $LFS/usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32

$MAKE

$MAKE exec_prefix=/usr install

$MAKE -C man install-man

echo "you WILL need to configure shadow later, idk how id do it here rn tho lmao"
