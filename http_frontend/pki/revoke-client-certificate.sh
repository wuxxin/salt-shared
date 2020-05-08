#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage:  $0 cert_name --yes

revokes an existing client certificate

EOF
    exit 1
}

certname="$1"
if test "$2" != "--yes"; then usage; fi

call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.user }}"
    echo "debug: called as root, using $call_prefix"
fi

# main
cd "{{ settings.cert_dir }}/easyrsa"
$call_prefix ./easyrsa --batch revoke "$certname"
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.user }}" -g "{{ settings.group }}" -m "0640" -T \
        "{{ settings.cert_dir }}/easyrsa/pki/crl.pem" \
        "{{ settings.cert_dir }}/{{ settings.ssl_client_crl }}"
