#!/bin/bash

usage() {
    cat <<EOF
Usage: $0 [--no-manual] datafile

takes (compressed) binary data,
encodes it in base32 and generates one alphanumeric qrcode,
and put this qrcode inside a pdf,

or if to large for one qrcode, encodes data in base32,
and generates max 100 x Version 29 alphanumeric qrcodes
and arranges them in a 2x2 matrix per page pdf

Option:
 * --no-manual : do NOT include a help page how to decode the qrcode PDF as last page of the pdf

Limits:
 * Single QRCode:
   * Medium Error Correction: Max Version 40:
     * 3391 alphanumeric (3376) => base32 <= 2110 Bytes (8 Bit)

 * manually linked QRCode, Version 29, 4 Codes per A4 Page (25 A4 Pages Maximum)
   * Medium Error Correction: 100 x Version 29:
     * 1839 alphanumeric (base32 decode of (1839 -6 (padding) -3 (split header) -4 (safety)= 1826): 
       * 1141 * 100 ~<= 114.100 (8 Bit)

QR-Code Standard:
 * Version 40: alphanumeric Limits: L 4296, M 3391, Q 2420, H 1852
 * Version 29: alphanumeric Limits: L 2369, M 1839, Q 1322, H 1016

Tests:
 * $0 --unittest

EOF
    exit 1
}

unittest() {

  for a in 2110 4200 19900 50000 114100; do
    x="test${a}"
    echo "a: $a x: $x"
    if test -f $x; then rm $x; fi
    if test -f ${x}.pdf; then rm ${x}.pdf; fi
    if test -f ${x}.new; then rm ${x}.new; fi
    touch $x
    shred -x -s $a $x
    data2pdf $x
    zbarimg --raw -q "-S*.enable=0" "-Sqrcode.enable=1" ${x}.pdf | 
       sort -n | cut -f 2 -d " " | tr -d "\n" | ./base32.py decode > ${x}.new
    diff $x ${x}.new
  done

}

make_decode_manual() {

convert -font "DejaVu Sans Mono" text:- $1 <<"EOF"
#!/bin/bash
# decode target: debian/ubuntu machine
# save and run this file under bash
# replace input with your images (*.png or pdf)
# replace output with your desired filename
input="*.png"; output="file.data"
export DEBIAN_FRONTEND=noninteractive
apt-get update; apt-get install zbar-tools
zbarimg --raw -q  "-S*.enable=0" "-Sqrcode.enable=1" $input |
sort -n | cut -f 2 -d " " | tr -d "\n" |
python -c "import sys, base64; \
sys.stdout.write(base64.b32decode(sys.stdin.read()))" > $output
EOF

}


data2pdf() {

  fname=`readlink -f $1`
  fbase=`basename $fname`
  fdir=`dirname $fname`
  fsize=`stat -c "%s" $fname`

  if test ! -f $fname; then 
    echo "ERROR: could not find datafile $fname; call "$0" for usage information"
    exit 2
  fi

  if test $fsize -gt 114100; then
    echo "ERROR: source file bigger than max capacity of 1141*100 bytes ($fsize); call "$0" for usage information"
    exit 3
  fi

  tempdir=`mktemp -d`
  if test ! -d $tempdir; then echo "ERROR: creating tempdir"; exit 1; fi
  if test "${tempdir:0:5}" != "/tmp/"; then echo "ERROR: creating tempdir"; exit 1; fi

  if test $fsize -le 2110; then
      cat $fname | ./base32.py encode | qrencode -o $tempdir/$fbase.png -l M -i
  else
      cat $fname | ./base32.py encode | split -a 2 -b 1826 -d - $tempdir/$fbase-
      for a in `ls $tempdir/$fbase-* | sort -n`; do 
          echo -n "${a: -2:2} " | cat - $a | qrencode -o $tempdir/`basename $a`.png -l M -i
      done
  fi
  list=`ls $tempdir/$fbase*.png | sort -n`
  montage -label '%f' -page A4 -tile 2x2 -geometry +10 $list $tempdir/${fbase}.pdf
  
  if test "$2" = "--no-manual"; then 
      cp $tempdir/${fbase}.pdf ${fbase}.pdf
  else
      make_decode_manual $tempdir/decode_manual.pdf
      pdftk $tempdir/${fbase}.pdf $tempdir/decode_manual.pdf cat output ${fbase}.pdf
  fi

  if test -d $tempdir; then 
    rm -r $tempdir
  fi
}


if test "$1" = ""; then usage; fi
if test "$1" = "--unittest"; then unittest; exit 0 ; fi
options=""; if test "$1" = "--no-manual"; then options=$1; shift; fi
data2pdf $1 $options
