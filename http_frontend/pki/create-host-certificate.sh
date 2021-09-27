#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 [--days daysvalid] domain [add domains*]
       $0 --is-listed domain [add domains*]
       $0 --renew domain

Creates / Renews a host certificate using the local ca.

+ The default certificate lifetime is $daysvalid days.

        result="false"
        if test -f "{{ domain_dir }}/fullchain.cer"; then
          if test -f "{{ domain_dir }}/{{ domain }}.cer"; then
            san_list=$(openssl x509 -text -noout -in "{{ domain_dir }}/{{ domain }}.cer" | \
              awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | \
              tr -d "DNS:" | tr "," "\\n" | sort)
            exp_list=$(echo "{{ san_list|join(' ') }}" | tr " " "\\n" | sort)
            if test "$san_list" = "$exp_list"; then result="true"; fi
          fi
        fi
        $result

EOF
    exit 1
}

daysvalid="{{ settings.ssl_pki_validity_days }}"
if test "$1" = "--days" -a "$2" != ""; then daysvalid=$2; shift 2; fi
if test "$1" = ""; then usage; fi
commonName="$1"
subjectAltName="DNS:$commonName"
shift
for i in $@; do
    subjectAltName="$subjectAltName,DNS:$i"
done
call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.ssl.user }}"
    echo "debug: called as root, using $call_prefix"
fi

# main
cd "{{ settings.ssl.base_dir }}/easyrsa"

# create cert
$call_prefix ./easyrsa --batch --passout=stdin \
    --use-algo="{{ settings.ssl_pki_algo }}" \
    --curve="{{ settings.ssl_pki_curve }}" \
    --days="$daysvalid" \
    --req-cn="$certname" \
    --subject-alt-name="${additional_san}" \
    --req-org="{{ settings.domain }} CA Server Cert" \
    build-host-full "$certname" nopass

# update revocation list
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.ssl.user }}" -g "{{ settings.ssl.user }}" -m "0640" -T \
        "{{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem" \
        "{{ settings.ssl.base_dir }}/{{ settings.ssl_local_crl }}"
