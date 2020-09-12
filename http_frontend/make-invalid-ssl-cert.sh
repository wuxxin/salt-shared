#!/usr/bin/bash
set -eo pipefail

HostName="invalid"
SubjectAltName="DNS:$HostName"
template="/usr/share/ssl-cert/ssleay.cnf"
cert_path="{{ settings.ssl_invalid_cert_path }}"
full_cert_path="{{ settings.ssl_invalid_full_cert_path }}"
key_path="{{ settings.ssl_invalid_key_path }}"
dhparam_path="{{ settings.cert_dir }}/{{ settings.ssl_dhparam }}"
TMPFILE="$(mktemp)" || exit 1
TMPOUT="$(mktemp)"  || exit 1
trap "rm -f $TMPFILE $TMPOUT" EXIT

sed -e s#@HostName@#"$HostName"# -e s#@SubjectAltName@#"$SubjectAltName"# $template > $TMPFILE
if ! openssl req -config $TMPFILE -new -x509 -days 3650 -nodes -sha256 \
    -out "$cert_path" -keyout "$key_path" > $TMPOUT 2>&1
then
    echo Could not create certificate. Openssl output was: >&2
    cat $TMPOUT >&2
    exit 1
fi
chmod 644 "$cert_path"
chmod 640 "$key_path"
chown root:ssl-cert "$key_path"
cat "$cert_path" "$dhparam_path" > "$full_cert_path"
chmod 644 "$full_cert_path"
