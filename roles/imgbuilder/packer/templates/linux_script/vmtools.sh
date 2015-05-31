#!/bin/bash

if test $PACKER_BUILDER_TYPE = 'virtualbox' ; then
    if type apt-get >/dev/null 2>&1; then
        echo "Installing VirtualBox guest additions (debian)"

        apt-get install -y linux-headers-$(uname -r) build-essential perl
        apt-get install -y dkms

        VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
        mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
        sh /mnt/VBoxLinuxAdditions.run --nox11
        umount /mnt
        rm /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso
    fi
fi
