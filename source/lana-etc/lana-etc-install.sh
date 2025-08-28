#!/bin/bash

set -e

rm -rf iana-etc-*

URL=$(curl -s https://api.github.com/repos/Mic92/iana-etc/releases/latest \
  | grep "browser_download_url" \
  | cut -d '"' -f 4 \
  | grep '\.tar\.gz$')

STAGE=$(basename "$URL" .tar.xz)
tar -xvf "$LATEST"

cd $STAGE
cp services protocols /tmp/choccynix/etc

