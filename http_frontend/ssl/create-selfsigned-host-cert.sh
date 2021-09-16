#!/usr/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 -k <keyfile_target> -c <certfile_target> [--days daysvalid] domain [additional domains*]

Creates a selfsigned host certificate.

+ The default certificate lifetime is $daysvalid days.

EOF
    exit 1
}

if test "$1" != "-k" -o "$3" != "-c" -o "$5" = ""; then usage; fi
key_path="$2"
cert_path="$4"
daysvalid={{ settings.ssl.days_valid }}
shift 4
if test "$1" = "--days" -a "$2" != ""; then
    daysvalid=$2
    shift 2
fi
commonName="$1"
subjectAltName="DNS:$commonName"
shift
for i in $@; do
    subjectAltName="$subjectAltName
subjectAltName=DNS:$i"
done
call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.ssl.pki.user }}"
    echo "debug: called as root, using $call_prefix"
fi

template="/usr/share/ssl-cert/ssleay.cnf"
TMPFILE="$(mktemp)" || exit 1
TMPOUT="$(mktemp)"  || exit 1
trap "rm -f $TMPFILE $TMPOUT" EXIT
sed -e s#@HostName@#"$commonName"# -e s#@SubjectAltName@#"$subjectAltName"# $template > $TMPFILE
if $call_prefix openssl req -config $TMPFILE -new -x509 -days $daysvalid -nodes -sha256 \
    -out "$cert_path" -keyout "$key_path" > $TMPOUT 2>&1
then
    echo Could not create certificate. Openssl output was: >&2
    cat $TMPOUT >&2
    exit 1
fi
chmod 644 "$cert_path"
chmod 640 "$key_path"
