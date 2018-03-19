#!/bin/bash

# exit the script if any statement returns a non-true value
set -e
realpath=$(dirname $(readlink -e "$0"))

check=false
if test "$1" = "--check"; then
    check=true
    shift
fi

# construct a xenial box as default
codename=${1:-xenial}
baseurl=https://cloud-images.ubuntu.com/$codename/current
basename=$codename-server-cloudimg-amd64
boxversion="$(http $baseurl/  | hxclean | hxselect -c title | grep -i "$codename" | sed -r 's/.*Build \[([0-9]+)\].*/\1/g').0.0"
basedir=~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-${codename}64/${boxversion}
virtualboxdir=$basedir/virtualbox
libvirtdir=$basedir/libvirt

mkdir -p $virtualboxdir
mkdir -p $libvirtdir
cd $basedir

# only check for metadata.yaml if --check
if $check; then
    test -e $libvirtdir/metadata.json
    return 0
fi

# check if box of type virtualbox is already there, download if not
if test ! -e $virtualboxdir/metadata.json; then
    vagrant box add --provider virtualbox ubuntu/xenial64
fi
test -e $virtualboxdir/metadata.json

cat > $libvirtdir/metadata.json << EOF
{
  "provider"     : "libvirt",
  "format"       : "qcow2",
  "virtual_size" : 10 
}
EOF
cat > $libvirtdir/Vagrantfile << EOF
Vagrant.configure("2") do |config|
    config.vm.provider :libvirt do |libvirt|
        libvirt.disk_bus = "virtio"
        libvirt.nic_model_type = "virtio"
        libvirt.video_type = 'vmvga'
        libvirt.volume_cache = 'none'
    end
end
EOF

echo "converting image $inputfile to QCOW2 box.img"
qemu-img convert -p -S 16k -O qcow2 $inputfile $libvirtdir/box.img

echo "information: done, new libvirt box named ubuntu/${codename}64 version $boxversion"

