#!/bin/bash
# the folder layout of the virtio changed recently
# use this script to convert it to the old layout

# usage: ./convert_virtio_iso.sh virtio-win.iso virtio-converted.iso

ORIG=/tmp/original_virtio
NEW=/tmp/new_virtio
mkdir -p $NEW/WIN8/AMD64 $ORIG
7z x $1 -o$ORIG
find $ORIG -type f -wholename '*2k12/amd64*' -exec mv {} $NEW/WIN8/AMD64/ \;
mkisofs -r -J -o $2 $NEW
rm -rf $NEW $ORIG
