#!/bin/bash
set -e

sudo rm -rf /tmp/choccynix
sudo mkdir /tmp/choccynix
sudo chown -R $(whoami):$(whoami) /tmp/choccynix

BASE_DIR="source"

for dir in "$BASE_DIR"/*/; do
    echo "Entering directory: $dir"
    
    for script in "$dir"*.sh; do
        if [[ -f "$script" ]]; then
            echo "Running $script..."
            notify-send "RUnning $script"
            bash "$script"
        fi
    done
done

