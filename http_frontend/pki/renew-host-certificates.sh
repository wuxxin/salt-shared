#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 --cron [--renew-hook <hook-shell-script.sh>]

Renews local issued host certificates using the local ca

Exit 0 on Success, Exit 1 on Error, Exit 2 on no renewal needed, no certificates renewed

+ --renwek-hook <hook-shell-script.sh>
    calls 'hook-shell-script.sh DOMAIN KEYFILE CERTFILE FULLCHAINFILE'
    for each domain renewed

EOF
    exit 1
}

if test "$1" != "--cron"; then usage; fi
shift
call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.ssl.user }}"
    echo "info: called as root, using $call_prefix"
fi

# main
cd "{{ settings.ssl.base_dir }}/easyrsa"

for commonName in all names; do
    # check if > minimum days valid

    # renew if not
    $call_prefix ./easyrsa --batch --passout=stdin \
        --use-algo="{{ settings.ssl.local_ca.algo }}" \
        --curve="{{ settings.ssl.local_ca.curve }}" \
        --days="$daysvalid" \
        renew "$certname" nopass

    # add local_ca to chain cert
    cat pki/issued/${certname}.crt pki/ca.crt | $call_prefix tee pki/issued/${certname}.fullchain.crt
done

# update revocation list
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.ssl.user }}" -g "{{ settings.ssl.user }}" -m "0640" -T \
        "{{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem" \
        "{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_crl }}"
