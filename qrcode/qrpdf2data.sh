#!/bin/bash

usage() {
    cat <<EOF
Usage: $0 {pdffile|multiple pictures} outputfile

example:
  $0 test.pdf test.zip
  $0 "*.png" test.dat

takes a pdf with qrcodes, decodes the qrcode and base32 decode the resulting output

EOF
    exit 1
}

if test "$1" = ""; then usage; fi
if test ! -f $1; then usage; fi

fname=`readlink -f $1`
fbase=`basename $fname`
fdir=`dirname $fname`
fsize=`stat -c "%s" $fname`

# zbarimg --raw -q "-S*.enable=0" "-Sqrcode.enable=1" $fname | tr -d "\n" | ./base32.py decode > $2

zbarimg --raw -q "-S*.enable=0" "-Sqrcode.enable=1" $fname |
    sort -n | cut -f 2 -d " " | tr -d "\n" | ./base32.py decode > $2
