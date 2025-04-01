#!/bin/bash
set -eo pipefail
set -x

usage(){
    cat << EOF
Usage: $0 [--is-valid] [--days <days>] <domain> [<domains>*]

Creates a host certificate using the local ca.

+ calling $0 --is-valid <domain> [<domains>*]
    will exit 0 if certificate exists, and all domains are listed in the current certificate,
    and exit 1 otherwise

+ The default certificate lifetime is $daysvalid days,
    use --days <days> to specify a different value

EOF
    exit 1
}

check_only="false"
daysvalid="{{ settings.ssl.local_ca.validity_days }}"
if test "$1" = "--is-valid"; then check_only="true"; shift; fi
if test "$1" = "--days"; then daysvalid=$2; shift 2; fi

if test "$1" = ""; then usage; fi
certname="$1"
subjectAltName="DNS:$certname"
san_list="$certname"
shift
for i in $@; do
    subjectAltName="$subjectAltName,DNS:$i"
    san_list="$san_list $i"
done
call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.ssl.user }}"
    echo "info: called as root, using $call_prefix"
fi

# main
cd "{{ settings.ssl.base_dir }}/easyrsa"

if test "$check_only" = "true"; then
    # check if current existing cert has all domains listed on commandline inside the cert
    cert_path="{{ settings.ssl.base_dir }}/easyrsa/pki/issued/${certname}.crt"
    if test -f "$cert_path"; then
        current_san_list=$(openssl x509 -text -noout -in "$cert_path" | \
            awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | \
            tr -d "DNS:" | tr "," "\\n" | sort)
        expected_san_list=$(echo "$san_list" | tr " " "\\n" | sort)
        echo "expected san_list: $expected_san_list"
        echo "current san_list: $current_san_list"
        if test "$current_san_list" = "$expected_san_list"; then
            exit 0
        fi
    fi
    exit 1
fi

# create cert
$call_prefix ./easyrsa \
    --batch \
    --use-algo="{{ settings.ssl.local_ca.algo }}" \
    --curve="{{ settings.ssl.local_ca.curve }}" \
    --keysize="{{ settings.ssl.local_ca.keysize }}" \
    --days="$daysvalid" \
    --dn-mode=org --req-cn="$certname" \
    --req-org="{{ settings.ssl.local_ca.organization }}" \
    --req-ou="{{ settings.ssl_local_ca_server_unit }}" \
    --req-email="" --req-city="" --req-st="" --req-c="" \
    --subject-alt-name="${subjectAltName}" \
    build-server-full "$certname" nopass

# add local_ca to chain cert
cat pki/issued/${certname}.crt pki/ca.crt | $call_prefix tee pki/issued/${certname}.fullchain.crt

# update revocation list
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.ssl.user }}" -g "{{ settings.ssl.user }}" -m "0640" -T \
        "{{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem" \
        "{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_crl }}"
