#!/bin/bash
self_path=$(dirname $(readlink -e "$0"))
. $self_path/options.include

cd $selfpath

echo "make archive of encrypted keys and shell scripts, convert that zip into a printable qrcode pdf"
tar caf $hostname.config.tar.xz . \
  --exclude $hostname.config.tar.xz \
  --exclude linux \
  --exclude initrd.gz \
  --exclude .vagrant \
  --exclude "*.iso" \
  --exclude "*.tar.xz" \
  --exclude "*.pdf"
  
./data2qrpdf.sh $hostname.config.tar.xz

if test -f $diskpassword_crypted; then
  echo "make diskpassword key only qrcode PDF"
  ./data2qrpdf.sh $diskpassword_crypted
fi
