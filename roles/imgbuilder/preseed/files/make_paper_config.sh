#!/bin/bash

echo "make archive of encrypted keys and shell scripts, convert that zip into a printable qrcode pdf"
tar caf {{ hostname }}.config.tar.xz . \
--exclude linux --exclude initrd.gz --exclude .vagrant --exclude "*.iso" --exclude "*.tar.xz" --exclude "*.pdf"
./data2qrpdf.sh {{ hostname }}.config.tar.xz

if test -f diskpassword.crypted; then
  echo "make diskpassword key only qrcode PDF"
  ./data2qrpdf.sh diskpassword.crypted
fi
