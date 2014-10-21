#!/bin/bash

usage() {
    cat <<EOF
Usage: $0 containername

takes a (compressed) binary container, encode in base32 and generate multiple qrcode codes, and arrange them in a 2x2 matrix for paper printing pdf

requisites: qrencode , imagemagick
decoding requires: zbar-tools

EOF
    exit 1
}

if test "$1" = ""; then usage; fi
if test ! -f $1; then usage; fi

rm $1*.png
cat $1 | ./base32.py encode | qrencode -o $1.png -l M -S -v 30
list=`ls $1*.png | sort -n`
montage -label '%f' -page A4 -tile 2x2 -geometry +10 $list ${1}.pdf
rm $1*.png
