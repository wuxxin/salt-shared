#!/bin/bash
set -e

if test "$4" = ""; then
    cat << EOF
Usage: $0 DOMAIN KEYFILE CERTFILE FULLCHAINFILE
EOF
    exit 1
fi

DOMAIN="${1}"; KEYFILE="${2}"; CERTFILE="${3}"; FULLCHAINFILE="${4}"
if test -e /usr/local/lib/gitops-library.sh; then
    . /usr/local/lib/gitops-library.sh
else
    simple_metric() {
         echo "$@"
    }
fi

if test "{{ settings.domain }}" != "$DOMAIN"; then
    subpath="vhost/$DOMAIN/"
    mkdir -m 0750 -p "{{ settings.cert_dir }}/vhost/$DOMAIN"
fi
simple_metric ssl_cert_renew counter \
    "timestamp of last cert-renew incovation" "$(date +%s)000"

install -m "0640" -T "$KEYFILE" "{{ settings.cert_dir }}/${subpath}{{ settings.ssl_key }}"
install -m "0640" -T "$CERTFILE" "{{ settings.cert_dir }}/${subpath}{{ settings.ssl_cert }}"
install -m "0640" -T "$FULLCHAINFILE" "{{ settings.cert_dir }}/${subpath}{{ settings.ssl_chain_cert }}"
cat "{{ settings.cert_dir }}/${subpath}{{ settings.ssl_chain_cert }}" "{{ settings.cert_dir}}/{{ settings.ssl_dhparam }}" > "{{ settings.cert_dir}}/${subpath}{{ settings.ssl_full_cert }}"
chmod 0640 "{{ settings.cert_dir }}/${subpath}{{ settings.ssl_full_cert }}"

valid_until=$(openssl x509 -in "{{ settings.cert_dir }}/${subpath}{{ settings.ssl_cert }}" -enddate -noout | \
    sed -r "s/notAfter=(.*)/\1/g")
simple_metric ssl_cert_valid_until gauge \
    "timestamp of certificate validity end date" \
    "$(date --date="$valid_until" +%s)000" "domain=\"$DOMAIN\""

{%- for command in settings.on_ssl_renew %}
{{ command }}
{%- endfor %}
