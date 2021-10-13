#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 --cron [--renew-hook <hook-shell-script.sh>]

Renews host certificates using the local ca

+ calls 'hook-shell-script.sh DOMAIN KEYFILE CERTFILE FULLCHAINFILE' on renewal

EOF
    exit 1
}

if test "$1" != "--cron"; then usage; fi
shift
call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.ssl.user }}"
    echo "debug: called as root, using $call_prefix"
fi
cd "{{ settings.ssl.base_dir }}/easyrsa"

# main
for commonName in all names; do
    # check if > minimum days valid
    # renew if not
    $call_prefix ./easyrsa --batch --passout=stdin \
        --use-algo="{{ settings.ssl_local_ca_algo }}" \
        --curve="{{ settings.ssl_local_ca_curve }}" \
        --days="$daysvalid" \
        --req-cn="$certname" \
        --subject-alt-name="${additional_san}" \
        --req-org="{{ settings.domain }} CA Server Cert" \
        build-host-full "$certname" nopass
done

# update revocation list
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.ssl.user }}" -g "{{ settings.ssl.user }}" -m "0640" -T \
        "{{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem" \
        "{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_crl }}"
