#!/bin/bash
set -e

umask 022

# the "filesystem"
export LFS=/tmp/choccynix

export MAKE="make -j$(nproc) DESTDIR=$LFS"

export LC_ALL=POSIX
export LFS_TGT=x86_64-lfs-linux-gnu
export LFS_TGT32=i686-lfs-linux-gnu
export LFS_TGTX32=x86_64-lfs-linux-gnux32
#export PATH=$LFS/usr/bin
#if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
#export PATH=$LFS/tools/bin:$PATH
export CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT LFS_TGT32 LFS_TGTX32 PATH

sudo rm -rf $LFS
sudo mkdir $LFS
sudo chown -R $(whoami):$(whoami) $LFS

export BASE_DIR="source"

for dir in "$BASE_DIR"/*/; do
    echo "Entering directory: $dir"
    
    for script in "$dir"*.sh; do
        if [[ -f "$script" ]]; then
            echo "Running $script..." >> compiled.txt
            chmod +x $script
            $script >> $script.log
        fi
    done
done

unset LFS LC_ALL LFS_TGT LFS_TGT32 LFS_TGTX32 

