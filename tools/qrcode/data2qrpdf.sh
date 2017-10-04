#!/bin/bash

usage() {
    cat <<EOF
Usage: $0 datafile

input (compressed) binary data,
encode base32 and generate one or more alphanumeric qrcodes,
arrange them in a 2x2 matrix per page pdf and output to \${datafile}.pdf

+ Single QRCode, Medium Error Correction, Version 40
    + 3378 base32 chars alphanumeric + overhead (13) = 3391 chars total
    + 1 Code Bytes = 2111 Bytes (8 Bit) Max

+ linked QRCode, Medium Error Correction, Version 31
    + 100 linked Codes maximum, 4 Codes per A4 Page, 25 A4 Pages
    + 1 Code Characters Chunksize = 2100 Chars (2113 Chars -6 padding -3 split header -4 safety)
    + 1 Code Bytes Chunksize = 1312 Bytes (base32decode(2225 chars))
    + 100 Codes Bytes = 131200 Bytes (8 Bit)

QR-Code (type alphanumeric) Dimensions:
    + Minimum Module Size on 300dpi(12dot/mm): 0.33mm
    + Double the Size for 150dpi(6dot/mm): 0.66mm

| Ver | Modules | min mm | Limits                         | char | bytes
| --- | ------- | ------ | ------------------------------ | ---- | -----
| 40  | 177x177 | 58,41  | L 4296, M 3391, Q 2420, H 1852 | 3378 | 2111
| 34  | 153x153 | 50,49  | L 3183, M 2506, Q 1787, H 1394 | 2493 | 1558
| 33  | 149x149 | 49,17  | L 3009, M 2369, Q 1700, H 1307 | 2356 | 1472
| 32  | 145x145 | 47,85  | L 2840, M 2238, Q 1618, H 1226 | 2225 | 1390
| 31  | 141x141 | 46,53  | L 2677, M 2113, Q 1499, H 1150 | 2100 | 1312
| 30  | 137x137 | 45,21  | L 2520, M 1994, Q 1429, H 1080 | 1981 | 1238
| 29  | 133x133 | 43,89  | L 2369, M 1839, Q 1322, H 1016 | 1826 | 1141
| 28  | 129x129 | 42,57  | L 2223, M 1732, Q 1263, H  958 | 1719 | 1074
| 27  | 125x125 | 41,25  | L 2132, M 1637, Q 1172, H  910 | 1624 | 1015

Tests:
 * $0 --unittest

EOF
    exit 1
}


unittest() {
    local a x
    local tempdir=`mktemp -d`
    if test ! -d $tempdir; then echo "ERROR: creating tempdir"; exit 1; fi
    cd $tempdir

    for a in $(( maxbytes_single -1 )) 4200 19900 50000 $(( maxbytes_chained -1 )); do
        x="test${a}"
        printf "test: $a "
        if test -f $x; then rm $x; fi
        if test -f ${x}.pdf; then rm ${x}.pdf; fi
        if test -f ${x}.new; then rm ${x}.new; fi
        touch $x
        shred -x -s $a $x
        printf "encoding "
        data2pdf $x
        printf "decoding "
        zbarimg --raw -q "-S*.enable=0" "-Sqrcode.enable=1" ${x}.pdf |
            sort -n | cut -f 2 -d " " | tr -d "\n" | python -c "import sys, base64; sys.stdout.write(base64.b32decode(sys.stdin.read()))" > ${x}.new
        printf "comparing "
        diff $x ${x}.new
        if test $? -eq 0; then
            rm $x ${x}.new $x.pdf
            echo ""
        else
            echo "Error: $x and $x.new differ, leaving $x $x.new and $x.pdf for analysis"
        fi
    done

    cd ..
    rm -r $tempdir
}


data2pdf() {
    local a
    local fname=`readlink -f $1`
    local fbase=`basename $fname`
    local fsize=`stat -c "%s" $fname`

    if test ! -f $fname; then
        echo "ERROR: could not find datafile $fname; call $0 for usage information"
        exit 2
    fi

    if test $fsize -gt $maxbytes_chained; then
        echo "ERROR: source file bigger than max capacity of $maxbytes_chained ($fsize); call $0 for usage information"
        exit 3
    fi

    local tempdir=$(mktemp -d)
    if test ! -d $tempdir; then echo "ERROR: creating tempdir"; exit 10; fi

    if test $fsize -le $maxbytes_single; then
        cat $fname | python -c "import sys, base64; \
            sys.stdout.write(base64.b32encode(sys.stdin.read()))" | \
            qrencode -l $level -i -t EPS -o "$tempdir/$fbase.eps"
        montage -label '%f' -page A4 -geometry +10 "$tempdir/$fbase.eps" ${fbase}.pdf
    else
        cat $fname | python -c "import sys, base64; \
            sys.stdout.write(base64.b32encode(sys.stdin.read()))" | \
            split -a 2 -b $maxchars_chunk -d - "$tempdir/$fbase-"
        for a in $(ls $tempdir/$fbase-* | sort -n); do
            echo -n "${a: -2:2} " | cat - $a | \
                qrencode -l $level -i -t EPS -o "$tempdir/$(basename $a).eps"
        done
        list=$(ls $tempdir/$fbase*.eps | sort -n | tr "\n" " ")
        montage -label '%f' -tile 2x2 -geometry +10 \
            $list "$tempdir/page-${fbase}-%d.eps"
        list=$(ls $tempdir/page-$base*.eps | sort -n | tr "\n" " ")
        convert -gravity east -format pdf $list ${fbase}.pdf
    fi

    if test -d $tempdir; then
        rm -r $tempdir
    fi
}

# main
maxchars_chunk=2100
maxbytes_chunk=1312
maxbytes_single=2111
maxbytes_chained=$(( maxbytes_chunk * 100))
level="M"

if test "$1" = ""; then usage; fi
if test "$1" = "--unittest"; then
    unittest
else
    data2pdf $1
fi
