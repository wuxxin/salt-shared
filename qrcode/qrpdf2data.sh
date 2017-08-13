#!/bin/bash

usage() {
    cat << EOF
Usage: $0 {pdffile|picture [picture]*} outputfile

example:
  $0 test.pdf test.zip
  $0 *.png env.yml.gz; gzip -d env.yml.gz

input linked qrcode pictures or a pdf with linked qrcodes.
decode the qrcodes and base32 decode the resulting output.
input order of pictures is not relevant for the output.

EOF
    exit 1
}

if test "$2" = ""; then usage; fi
if test ! -f $1; then usage; fi

if ! which zbarimg > /dev/null; then
    echo "error, no zbarimg found. try 'apt install zbar-tools'"
    exit 1
fi

# get last parameter and remove from args
outputfile=${@:${#@}}
set -- "${@:1:$(($#-1))}"

zbarimg --raw -q "-S*.enable=0" "-Sqrcode.enable=1" $@ |
    sort -n | cut -f 2 -d " " | tr -d "\n" |
    python -c "import sys, base64; \
        sys.stdout.write(base64.b32decode(sys.stdin.read()))" > $outputfile
