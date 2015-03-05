#!/bin/sh

umask 077
set -e
# come up with a decent directory to compose in
dir=$(mktemp -d)
cd_size=700000000
oldpwd=$(pwd)
cd $dir
mkdir cd-files
cp /var/lib/aide/* cd-files/
cp /var/cfengine/checksum_digests.db cd-files/
mkisofs -RJ -o baseline-backup.iso -V "$(hostname) baseline"
size=$(stat -c %s baseline-backup.iso)
if [ $size -lt $cd_size ]; then
    cdrecord -data baseline-backup.iso
    cd $oldpwd
    rm -rf $dir
else
    # Since this script is intended to be run manually, I don't expect anyone
    # to be able to deny service by causing the baseline backup to be too big:
    # the admin will be sitting there watching it happen and will clean up.
    echo "Baseline backup $size is bigger than a CD ($cd_size bytes)" >&2
    echo "Not proceeding farther" >&2
    exit 1
fi
