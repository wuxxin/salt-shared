#!/bin/bash
set -eo pipefail
set -x

self_path=$(dirname "$(readlink -e "$0")")


usage() {
    cat <<EOF
Usage: $0 --yes [--with-recovery] [optional args to build-custom-zfs.sh]

build and install a custom zfs version for:
+ the running system
+ the initrd of the running system
+ if "--with-recovery", the recovery squashfs

for activation a reboot is needed after execution.

EOF
    exit 1
}

# parse args
if test "$1" != "--yes"; then usage; fi
shift
run_recovery="false"
if test "$1" = "--with-recovery"; then
    shift
    run_recovery="true"
fi

# build custom zfs
basedir=$(mktemp -d)
echo "build-custom-zfs ($@) at $basedir"
"$self_path/build-custom-zfs.sh" "$basedir" $@

# move build artifacts and configure local machine to use them
custom_archive=/usr/local/lib/bootstrap-custom-archive
custom_sources_list=/etc/apt/sources.list.d/local-bootstrap-custom.list
if test -e $custom_archive; then rm -rf $custom_archive; fi
mkdir -p $custom_archive
mv -t $custom_archive $basedir/build/buildresult/*
rm -rf "$basedir"
cat > $custom_sources_list << EOF
deb [ trusted=yes ] file:$custom_archive ./
EOF
DEBIAN_FRONTEND=noninteractive apt-get update --yes

echo "install/upgrade packages in running system"
zfs_packages="spl-dkms zfs-dkms zfsutils-linux zfs-dracut zfs-zed"
DEBIAN_FRONTEND=noninteractive apt-get install --upgrade --yes $zfs_packages

if test "$run_recovery" = "true"; then
    echo "updating recovery.squashfs"
    /etc/recovery/update-recovery-squashfs.sh --host
fi
