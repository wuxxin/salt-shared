#!/bin/bash
set -e


usage() {
    cat <<EOF
Usage: $0 [--codename codename] [--daily] [--only-lxd|--only-libvirt] [--yes|--check]

download and modify an ubuntu vagrant box for virtualbox, libvirt & lxd

default codename=$codename 
remark: needs lxd running for vagrant lxd container

EOF
    exit 1
}


codename2version() {
    codename=$1
    case $codename in
        trusty) echo "14.04" ;;
        xenial) echo "16.04" ;;
        artful) echo "17.10" ;;
        bionic) echo "18.04" ;;
    esac
}


virtualbox_to_libvirt() {
    local codename boxversion virtualboxdir libvirtdir 
    codename=$1
    boxversion=$2
    virtualboxdir=$3
    libvirtdir=$4
    
    # check if box of type virtualbox is already there
    test -e $virtualboxdir/metadata.json

    echo "information: repack vagrant virtualbox into vagrant libvirt layout"
    mkdir -p $libvirtdir
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
        # XXX qemu < 2.9.0 and cpu:mode=host-model dont always work
        # xenial kernel modul raid6 hangs on mismatch between avx2 support flag and acutal availability of avx2
        libvirt.cpu_feature :name => 'avx2', :policy => 'disable'
    end
end
EOF

    inputfile=$virtualboxdir/*-cloudimg.vmdk
    echo "converting image $inputfile to QCOW2 box.img"
    qemu-img convert -p -S 16k -O qcow2 $inputfile $libvirtdir/box.img

    echo "information: done, new libvirt box named ubuntu/${codename}64 version $boxversion"
}


download_convert_virtualbox() {
    local basedir baseurl basename baselist boxversion virtualboxdir libvirtdir
    local keyid real_fingerprint expected_fingerprint
    codename="$1"
    daily="$2"
    
    # construct box url and version
    if test "$daily" = "true"; then
        baseurl="https://cloud-images.ubuntu.com/daily/server/$codename/current"
        basename="$codename-server-cloudimg-$arch"
        boxversion="$(curl -L -s $baseurl/  | hxclean | hxselect -c title | grep -i "$codename" | sed -r 's/.*Build \[([0-9\.]+)\].*/\1/g')"
    else
        releasever=$(codename2version $codename)
        baseurl="https://cloud-images.ubuntu.com/releases/$codename/release"
        basename="ubuntu-$releasever-server-cloudimg-$arch"
        boxversion="$(curl -L -s $baseurl/unpacked/build-info.txt | grep '^serial' | sed -r 's/serial=(.*)/\1/')"
    fi    
    if ! $(echo "$boxversion" | grep -q -E "[0-9]+\.[0-9]+\.[0-9]+"); then
        boxversion="${boxversion}.0"
    fi
    if ! $(echo "$boxversion" | grep -q -E "[0-9]+\.[0-9]+\.[0-9]+"); then
        boxversion="${boxversion}.0"
    fi
    basedir=~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-${codename}64/${boxversion}
    virtualboxdir=$basedir/virtualbox
    libvirtdir=$basedir/libvirt

    # create directory,metadata, change to basedir
    mkdir -p $basedir   
    echo -n "https://vagrantcloud.com/ubuntu/${codename}64" > "$(dirname $basedir)/metadata_url"
    cd $basedir

    # get cdimage@ubuntu.com gpg key
    if test -e gpghome; then rm -rf gpghome; fi
    mkdir -m 0700 gpghome
    keyid="7DB87C81"
    expected_fingerprint="D2EB 4462 6FDD C30B 513D  5BB7 1A5D 6C4C 7DB8 7C81"
    gpg --quiet --homedir gpghome --batch --yes --keyserver keyserver.ubuntu.com --recv-keys $keyid 
    real_fingerprint=$(LC_MESSAGES=POSIX gpg --quiet --homedir gpghome --fingerprint $keyid | grep "fingerprint = " | sed -r "s/.*= (.*)/\1/g")
    if test "$expected_fingerprint" != "$real_fingerprint"; then
        echo "error: fingerprint mismatch: expected: $expected_fingerprint , real: $real_fingerprint"
        return 1
    fi
    gpg --quiet --homedir gpghome --export $keyid > "$basedir/cdimage@ubuntu.com.gpg"
    rm -rf gpghome
        
    # get checksum files
    for i in SHA256SUMS SHA256SUMS.gpg; do
        echo "get $baseurl/$i"
        curl -L -s "$baseurl/$i" > $i
    done

    # check gnupg signing key for sha256sums
    echo "information: check if gpg key is signed by ubuntu"
    gpgv --keyring=$basedir/cdimage@ubuntu.com.gpg SHA256SUMS.gpg SHA256SUMS

    # get files and check sha256sums
    baselist="$basename-vagrant.box"
    for i in $baselist; do
        if test ! -e $i; then
            echo "get $baseurl/$i"
            curl -L -s "$baseurl/$i" > $i
        fi
        echo "information: check sha256sum of $i"
        grep "$i" SHA256SUMS | sha256sum --check
    done
    
    mkdir -p $virtualboxdir
    tar xf $basedir/${basename}-vagrant.box -C $virtualboxdir
    
    virtualbox_to_libvirt $codename $boxversion $virtualboxdir $libvirtdir
}


download_convert_lxcd() {
    local codename boxversion lxcdir lxddir lxdconfig rootfs cloudblock
    codename=$1
    cloudblock=$scriptpath/cloud-init-block.yaml
    if test ! -e $cloudblock; then
        cloudblock=/usr/local/share/vagrant/cloud-init-block.yaml    
    fi
    if test "$daily" = "true"; then
        boxversion=$(lxc image show ubuntu-daily:$codename/$arch --format yaml | grep "serial:" | sed -r 's/.*serial: "([0-9\.]+)"/\1/')
        basename="$codename-server-cloudimg-$arch"
    else
        releasever=$(codename2version $codename)
        boxversion=$(lxc image show ubuntu:$codename/$arch --format yaml | grep "serial:" | sed -r 's/.*serial: "([0-9\.]+)"/\1/')
        basename="ubuntu-$releasever-server-cloudimg-$arch"
    fi
    if ! $(echo "$boxversion" | grep -q -E "[0-9]+\.[0-9]+\.[0-9]+"); then
        boxversion="${boxversion}.0"
    fi
    if ! $(echo "$boxversion" | grep -q -E "[0-9]+\.[0-9]+\.[0-9]+"); then
        boxversion="${boxversion}.0"
    fi

    basedir=~/.vagrant.d/boxes/ubuntu-VAGRANTSLASH-${codename}64/${boxversion}
    lxddir=$basedir/lxd
    lxcdir=$basedir/lxc
    lxdconfig=${basename}-lxd.tar.xz
    rootfs=${basename}.squashfs
        
    # create directory,metadata, change to basedir
    mkdir -p $basedir   
    echo -n "https://vagrantcloud.com/ubuntu/${codename}64" > "$(dirname $basedir)/metadata_url"
    cd $basedir
    
    echo "information: download ubuntu lxd container"
    mkdir -p $lxcdir $lxddir
    #lxc image export ubuntu:$codename/$arch $basedir
    echo "xxx todo fixme: write checksum, redownload when ?"
    
    echo "information: convert lxd container to vagrant lxd friendly layout"
    fakeroot -- bash -c "\
    if test -e temp; then rm -rf temp; fi; mkdir -p temp; \
    echo 'extract rootfs'; \
    unsquashfs -d temp/rootfs $rootfs; \
    echo 'extract lxd metadata'; \
    tar xf $lxdconfig -C temp; \
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
}



# main
scriptpath=$(dirname $(readlink -e "$0"))
codename=bionic
arch=amd64
daily=false
onylxd=false
onlylibvirt=false
acknowledged=false
check=false

while true; do
    case $1 in
    -c|--codename)
        codename=$2
        shift
        ;;
    -d|--daily)
        daily=true
        ;;
    -x|--only-lxd)
        onlylxd=true
        ;;
    -l|--only-libvirt)
        onlylibvirt=true
        ;;
    -c|--check)
        check=true
        ;;
    -y|--yes)
        acknowledged=true
        ;;
    *)
        break
        ;;
    esac
    shift
done

if test "$acknowledged" != "true" -a "$check" != "true"; then
    usage
fi
if ! $onlylxd; then
    download_convert_virtualbox "$codename" "$daily" "$check"
fi
if ! $onlylibvirt; then
    download_convert_lxcd "$codename" "$daily" "$check"
fi
