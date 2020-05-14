#!/bin/bash
set -e

DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"
if test -e /usr/local/lib/gitops-library.sh; then
    . /usr/local/lib/gitops-library.sh
else
    simple_metric() {
         echo "$@"
    }
fi
simple_metric ssl_cert_acme_renew counter \
    "timestamp since last renew of letsencrypt cert" "$(date +%s)000"

install -o "{{ settings.user }}" -g "{{ settings.group }}" -m "0640" -T \
        "$KEYFILE" "{{ settings.cert_dir }}/server.key.pem"
install -o "{{ settings.user }}" -g "{{ settings.group }}" -m "0640" -T \
        "$FULLCHAINFILE" "{{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}"
cat "{{ settings.cert_dir }}/{{ settings.ssl_chain_cert }}" "{{ settings.cert_dir}}/{{ settings.ssl_dhparam }}" > "{{ settings.cert_dir}}/{{ settings.ssl_full_cert }}"
chmod 0640 "{{ settings.cert_dir }}/{{ settings.ssl_full_cert }}"
chown "{{ settings.user }}:{{ settings.group }}" "{{ settings.cert_dir }}/{{ settings.ssl_full_cert }}"

valid_until=$(openssl x509 -in "$CERTFILE" -enddate -noout | sed -r "s/notAfter=(.*)/\1/g")
simple_metric ssl_cert_acme_valid_until gauge \
    "timestamp of certificate validity end date" \
    "$(date --date="$valid_until" +%s)000" "domain=\"$DOMAIN\""

{%- for command in settings.on_ssl_renew %}
{{ command }}
{%- endfor %}
