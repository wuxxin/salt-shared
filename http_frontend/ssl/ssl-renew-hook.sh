#!/bin/bash
set -eo pipefail
set -x

usage(){
    cat << EOF
Usage: $0 [--no-hooks] DOMAIN KEYFILE CERTFILE FULLCHAINFILE [CACERTFILE]

copy/installs certs into the target directories
{{ settings.ssl.base_dir }}/vhost/*
so they are picked up by eg. nginx and others.

after installation, it will execute all entries in settings.ssl.on_renew hooks
as user ssl.user with env vars set: DOMAIN, KEYFILE, CERTFILE, FULLCHAINFILE,
**except** on first creation (no old key file in the target directory),
**or** --no-hooks is specified.
EOF
    exit 1
}

execute_hooks="true"
if test "$1" = "--no-hooks"; then execute_hooks="false"; shift; fi
if test "$4" = "" -o "$1" = "--help" -o "$1" = "help"; then usage; fi
DOMAIN="${1}"; KEYFILE="${2}"; CERTFILE="${3}"; FULLCHAINFILE="${4}" CACERTFILE="${5}"
export DOMAIN; export KEYFILE; export CERTFILE; export FULLCHAINFILE; export CACERTFILE

if test -e /usr/local/lib/gitops-library.sh; then
    . /usr/local/lib/gitops-library.sh
else
    simple_metric() {
        echo "$@"
    }
fi
domain_dir="{{ settings.ssl.base_dir }}/vhost/$DOMAIN"
mkdir -m 0750 -p "$domain_dir"

simple_metric ssl_cert_renew counter \
    "timestamp of last cert-renew incovation" "$(date +%s)000"
if test ! -e "${domain_dir}/{{ settings.ssl_key }}"; then
    execute_hooks="false"
fi

install -m "0640" -T "$KEYFILE" "${domain_dir}/{{ settings.ssl_key }}"
install -m "0644" -T "$CERTFILE" "${domain_dir}/{{ settings.ssl_cert }}"
install -m "0644" -T "$FULLCHAINFILE" "${domain_dir}/{{ settings.ssl_chain_cert }}"

valid_until=$(openssl x509 -in "${domain_dir}/{{ settings.ssl_cert }}" \
    -enddate -noout | sed -r "s/notAfter=(.*)/\1/g")
simple_metric ssl_cert_valid_until gauge \
    "timestamp of certificate validity end date" \
    "$(date --date="$valid_until" +%s)000" "domain=\"$DOMAIN\""

if test "$execute_hooks" = "true"; then
{%- for command in settings.ssl.on_renew %}
{{ command }}
{%- endfor %}
fi
