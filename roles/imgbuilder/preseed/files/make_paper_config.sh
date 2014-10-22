#!/bin/bash

echo "make archive of encrypted keys and shell scripts, convert that zip into a printable qrcode pdf"
tar cf {{ hostname }}.config.tar.xz . --exclude linux --exclude initrd.gz --exclude .vagrant --exclude {{ hostname }}.config.tar.xz
./data2qrpdf.sh {{ hostname }}.config.tar.xz

echo "make diskpassword key only qrcode PDF"
./data2qrpdf.sh diskpassword.crypted
