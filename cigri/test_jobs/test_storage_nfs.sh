#!/bin/bash
echo $2 > $1
sleep 30
dd if=/dev/zero of=/srv/shared/file-nfs-$1 bs=$3 count=1 oflag=direct
