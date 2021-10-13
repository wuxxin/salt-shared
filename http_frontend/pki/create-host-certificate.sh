#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 [--days daysvalid] domain [add domains*]
       $0 --check-domains-listed domain [add domains*]

Creates a host certificate using the local ca.

+ calling $0 --check-domains-listed domain [domains*]
    will exit 0 if all domains are listed in the current existing certificate,
    and exit 1 otherwise

+ The default certificate lifetime is $daysvalid days,
    use --days daysvalid to specify a different value

EOF
    exit 1
}

check_only="false"
daysvalid="{{ settings.ssl_local_ca_validity_days }}"
if test "$1" = "--days"; then daysvalid=$2; shift 2; fi
if test "$1" = "--check-domains-listed"; then check_only="true"; shift; fi
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
    echo "debug: called as root, using $call_prefix"
fi
cd "{{ settings.ssl.base_dir }}/easyrsa"

if test "$check_only" = "true"; then
    # check if current existing cert has all domains listed on commandline inside the cert
    cert_path="{{ settings.ssl.base_dir }}/easyrsa/pki/issued/${certname}.crt"
    if test -f "$cert_path"; then
        current_san_list=$(openssl x509 -text -noout -in "$cert_path" | \
            awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | \
            tr -d "DNS:" | tr "," "\\n" | sort)
        expected_san_list=$(echo "$san_list" | tr " " "\\n" | sort)
        if test "$current_san_list" = "$expected_san_list"; then
            exit 0
        fi
    fi
    exit 1
fi

# create cert
$call_prefix ./easyrsa --batch \
    --use-algo="{{ settings.ssl_local_ca_algo }}" \
    --curve="{{ settings.ssl_local_ca_curve }}" \
    --days="$daysvalid" \
    --req-cn="$certname" \
    --subject-alt-name="${subjectAltName}" \
    --req-org="{{ settings.domain }} CA Server Cert" \
    build-server-full "$certname" nopass

# update revocation list
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.ssl.user }}" -g "{{ settings.ssl.user }}" -m "0640" -T \
        "{{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem" \
        "{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_crl }}"
