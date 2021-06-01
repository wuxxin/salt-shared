#!/usr/bin/bash
set -eo pipefail

if test "$1" != "-k" -o "$3" != "-c" -o "$5" = ""; then
    cat << EOF
Usage: $0 -k <keyfile_target> -c <certfile_target> domain [additional-san]*
EOF
    exit 1
fi

template="/usr/share/ssl-cert/ssleay.cnf"
key_path="$2"
cert_path="$4"
commonName="$5"
subjectAltName="DNS:$commonName"
shift 5
for i in $@; do
    subjectAltName="$subjectAltName
subjectAltName=DNS:$i
"
done
TMPFILE="$(mktemp)" || exit 1
TMPOUT="$(mktemp)"  || exit 1
trap "rm -f $TMPFILE $TMPOUT" EXIT

sed -e s#@HostName@#"$commonName"# -e s#@SubjectAltName@#"$subjectAltName"# $template > $TMPFILE
if ! openssl req -config $TMPFILE -new -x509 -days 3650 -nodes -sha256 \
                -out "$cert_path" -keyout "$key_path" > $TMPOUT 2>&1
then
    echo Could not create certificate. Openssl output was: >&2
    cat $TMPOUT >&2
    exit 1
fi
chmod 644 "$cert_path"
chmod 640 "$key_path"
