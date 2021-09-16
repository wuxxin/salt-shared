#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 -k <keyfile_target> -c <certfile_target> [--days daysvalid] domain [additional domains*]

Creates a host certificate.

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
    subjectAltName="$subjectAltName,DNS:$i"
done
call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.ssl.pki.user }}"
    echo "debug: called as root, using $call_prefix"
fi

# main
cd "{{ settings.ssl.pki.data }}/easyrsa"

# create cert
$call_prefix ./easyrsa --batch --passout=stdin \
    --use-algo="{{ settings.ssl.pki.algo }}" --curve="{{ settings.ssl.pki.curve }}" \
    --days="$daysvalid" \
    --req-cn="$certname" \
    --subject-alt-name="${additional_san}" \
    --req-org="{{ settings.domain }} CA Server Cert" \
    build-host-full "$certname"

# update revocation list
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.ssl.pki.user }}" -g "{{ settings.ssl.pki.user }}" -m "0640" -T \
        "{{ settings.ssl.pki.data }}/easyrsa/pki/crl.pem" \
        "{{ settings.ssl.pki.data }}/{{ settings.ssl_local_crl }}"
