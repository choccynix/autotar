#!/bin/bash
set -e

umask 022

# the "filesystem"
LFS=/tmp/choccynix

MAKE="make -j$(nproc) DESTDIR=$LFS"

LC_ALL=POSIX
LFS_TGT=x86_64-lfs-linux-gnu
LFS_TGT32=i686-lfs-linux-gnu
LFS_TGTX32=x86_64-lfs-linux-gnux32
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT LFS_TGT32 LFS_TGTX32 PATH

sudo rm -rf $LFS
sudo mkdir $LFS
sudo chown -R $(whoami):$(whoami) $LFS

BASE_DIR="source"

for dir in "$BASE_DIR"/*/; do
    echo "Entering directory: $dir"
    
    for script in "$dir"*.sh; do
        if [[ -f "$script" ]]; then
            echo "Running $script..." >> compiled.txt
            notify-send "RUnning $script"
            bash "$script" >> $script.log
        fi
    done
done

