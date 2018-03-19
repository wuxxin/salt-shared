#!/bin/bash

usage() {
    cat << EOF
$(basename $0) --key keyfile         [options] output.iso
$(basename $0) --vagrant[-password]  [options] output.iso
$(basename $0) --custom custom.env   [options] output.iso

purpose: creates a cidata cloud-init config iso with configureable content
+ "--key keyfile" configures a ssh publickeyfile for user root
+ "--vagrant" configures a vagrant user with the insecure vagrant public key
+ "--vagrant-password" configures a vagrant user with insecure passsword "vagrant"
+ "--custom customfile" supply custom user-data for config iso

options:
+ "--grow-root" to grow root partition on first boot
    and install cloud-initramfs-growroot on first startup
+ "--add-meta-data" filename
    to add contents of filename to meta data section
+ "--add-user-data" filename
    to add contents of filename to user data section

requirements:
+ genisoimage, openssl; on ubuntu/debian use "apt install genisoimage openssl".

EOF
    exit 1
}


vagrant_publickey="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
userdata=""
useroptional=""
metaoptional=""
cmd="$1"
shift
for i in genisoimage openssl; do
    if ! which $i > /dev/null; then echo "error: $i not found"; usage; fi
done


if test "$cmd" = "--all-vagrant"; then
    $0 --vagrant vagrant-publickey.iso
    $0 --vagrant --grow-root vagrant-publickey-growroot.iso
    $0 --vagrant-password vagrant-password.iso
    $0 --vagrant-password --grow-root vagrant-password-growroot.iso
    exit 0
elif test "$cmd" = "--vagrant" -o "$cmd" = "--vagrant-password"; then
    if test "$cmd" = "--vagrant-password"; then
        vagrant_password_data='    lock-passwd: False
    passwd: $6$VAX3VZ0i$ZCvAQtdYS3WsxWMR3SZC2QtteLdyg7EiZgV/E8QdWB361.lsPZ5pyh6gMob2UqtWRj7B1Pc6qzy4xypDxMQZ8/

chpasswd:
  expire: False
ssh_pwauth: True
'
    else
        vagrant_password_data=''
    fi
    userdata="#cloud-config
users:
  - name: vagrant
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $vagrant_publickey

$vagrant_password_data
"
elif test "$cmd" = "--key"; then
    if test ! -e "$1"; then echo "error: ssh publickeyfile $1 not found"; usage; fi
    userdata="#cloud-config
ssh_authorized_keys:
  - $(cat $1)
disable_root: false
"
    shift
elif test "$cmd" = "--custom"; then
    if test ! -e "$1"; then echo "error: custom env $1 not found"; usage; fi
    userdata="$(cat $1)"
    shift
else
    if test "$cmd" != ""; then echo "error: wrong argument $cmd"; fi
    usage
fi



while test "$1" != ""; do
    opt=$1
    case $opt in
        --grow-root)
            useroptional="${useroptional}
resize_rootfs: True
packages:
  - cloud-initramfs-growroot
"
            shift
            ;;
        --add-meta-data)
            metaoptional="${metaoptional}
$(cat $2)
"
            shift 2
            ;;
        --add-user-data)
            useroptional="${useroptional}
$(cat $2)
"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done


if test "$1" = ""; then echo "error: missing output filename"; usage; fi
outputfilename="$1"
tempdir=$(mktemp -d)
if test ! -d $tempdir; then echo "ERROR: creating tempdir"; exit 1; fi

cat > $tempdir/user-data <<END
$userdata
$useroptional

END

# Create fake meta-data
cat > $tempdir/meta-data <<END
instance-id: iid-$(openssl rand -hex 8)
local-hostname: nocloud
$metaoptional

END

# Create the ISO
genisoimage \
    -quiet -volid cidata -joliet -rock -input-charset utf-8 -graft-points \
    -output "$outputfilename" \
    user-data=$tempdir/user-data \
    meta-data=$tempdir/meta-data
rm -r $tempdir
echo "Generated $outputfilename"
