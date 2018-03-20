#!/bin/bash

# exit the script if any statement returns a non-true value
set -e
realpath=$(dirname $(readlink -e "$0"))

# requisites
#apt-get install fakeroot gnupg xz-utils

check=false
if test "$1" = "--check"; then
    check=true
    shift
fi
# construct a xenial lxd box as default
codename=${1:-xenial}
arch=amd64
baseurl=https://cloud-images.ubuntu.com/$codename/current
basename=$codename-server-cloudimg-${arch}
baselist="$basename-lxd.tar.xz $basename-root.tar.xz"
boxversion="$(http $baseurl/  | hxclean | hxselect -c title | grep -i "$codename" | sed -r 's/.*Build \[([0-9]+)\].*/\1/g').0.0"
basedir=~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-${codename}64/${boxversion}
lxddir=$basedir/lxd
lxcdir=$basedir/lxc
cloudblock=$realpath/cloud-init-block.yaml
if test ! -e $cloudblock; then
cloudblock=/usr/local/share/vagrant/cloud-init-block.yaml    
fi

mkdir -p $lxddir
mkdir -p $lxcdir
cd $basedir

# only check for metadata.yaml if --check
if $check; then
    test -e $lxddir/metadata.yaml
    return 0
fi

# get gnupg key
if test -e gpghome; then rm -rf gpghome; fi
mkdir -m 0700 gpghome
keyid="7DB87C81"
expected_fingerprint="D2EB 4462 6FDD C30B 513D  5BB7 1A5D 6C4C 7DB8 7C81"
gpg --homedir gpghome --batch --yes --keyserver keyserver.ubuntu.com --recv-keys $keyid 
real_fingerprint=$(LC_MESSAGES=POSIX gpg --homedir gpghome --fingerprint $keyid | grep "fingerprint = " | sed -r "s/.*= (.*)/\1/g")
if test "$expected_fingerprint" != "$real_fingerprint"; then
    echo "error: fingerprint mismatch: expected: $expected_fingerprint , real: $real_fingerprint"
    return 1
fi
gpg --homedir gpghome --export $keyid > "$basedir/cdimage@ubuntu.com.gpg"
rm -rf gpghome

# get checksum files
for i in SHA256SUMS SHA256SUMS.gpg; do
    echo "get $baseurl/$i"
    http $baseurl/$i > $i
done
# check gnupg signing key for sha256sums
echo "information: check if gpg key is signed by ubuntu"
gpgv --keyring=$basedir/cdimage@ubuntu.com.gpg SHA256SUMS.gpg SHA256SUMS

# get files and check sha256sums
for i in $baselist; do
    if test ! -e $i; then
        echo "get $baseurl/$i"
        http $baseurl/$i > $i
    fi
    echo "information: check sha256sum of $i"
    grep "$i" SHA256SUMS | sha256sum --check
done

echo "information: repack into vagrant-lxd friendly layout"


fakeroot -- bash -c "\
if test -e temp; then rm -rf temp; fi; mkdir -p temp/rootfs; \
echo 'extract rootfs'; \
tar xf $basename-root.tar.xz -C temp/rootfs; \
echo 'extract lxd metadata'; \
tar xf $basename-lxd.tar.xz -C temp; \
echo 'create lxc rootfs'; \
tar czf lxc-rootfs.tar.gz --numeric-owner -C temp rootfs; \
echo source_fingerprint:\ \$(sha256sum -b lxc-rootfs.tar.gz | sed -r 's/([^ ]+) .*/\1/g') >> temp/metadata.yaml; \
cp temp/metadata.yaml .; \
cp $cloudblock temp/templates/cloud-init-user.tpl
chown 0:0 temp/templates/cloud-init-user.tpl
echo 'create lxd rootfs'; \
tar czf lxd-rootfs.tar.gz --numeric-owner -C temp rootfs templates metadata.yaml; \
rm -rf temp"

mv lxc-rootfs.tar.gz $lxcdir/rootfs.tar.gz
mv lxd-rootfs.tar.gz $lxddir/rootfs.tar.gz
mv metadata.yaml $lxddir
cat > $lxcdir/metadata.json << EOF
{
  "provider": "lxc",
  "version":  "${boxversion}",
  "built-on": "$(LC_ALL=posix date)",
  "template-opts": {
    "--arch":    "${arch}",
    "--release": "${codename}"
  }
}
EOF
cat > $lxcdir/lxc-config << EOF
# For additional config options, please look at lxc.container.conf(5)

# Common configuration
lxc.include = /usr/share/lxc/config/ubuntu.common.conf

# settings for systemd with PID 1:
lxc.kmsg = 0
lxc.autodev = 1
# allow unconfined and incomplete
lxc.aa_profile = unconfined
lxc.aa_allow_incomplete = 1
EOF

echo "information: done, new lxc/lxd box named ubuntu/${codename}64 version $boxversion"

