#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage:  $0 cert_name --yes

revokes an existing certificate

EOF
    exit 1
}

certname="$1"
if test "$2" != "--yes"; then usage; fi

call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.ssl.user }}"
    echo "debug: called as root, using $call_prefix"
fi

# main
cd "{{ settings.ssl.basedir }}/easyrsa"
$call_prefix ./easyrsa --batch revoke "$certname"
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.ssl.user }}" -g "{{ settings.ssl.user }}" -m "0640" -T \
        "{{ settings.ssl.basedir }}/easyrsa/pki/crl.pem" \
        "{{ settings.ssl.basedir }}/{{ settings.ssl_local_crl }}"
