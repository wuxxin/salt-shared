#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage:  $0 user-email@address.domain cert_name [--days daysvalid]

Creates a client certificate, and send certificate via Email.

+ The default certificate lifetime is $daysvalid days.
    + Change this by supplying --days number-of-days
+ The password is generated using "openssl rand -base64 $randbytes" = $(( randbytes *8 )) bits entropy encoded base64

EOF
    exit 1
}

randbytes=15
base64size=$(echo "if (($randbytes * 8) > ($randbytes * 8 /6 *6)) { $randbytes * 8 /6 +1} else { $randbytes *8 /6 }" | bc)
daysvalid=1095
place=""
user=""
subject=""
call_prefix=""

if test "$2" = ""; then usage; fi
email="$1"
certname="$2"
shift 2
if test "$1" = "--days" -a "$2" != ""; then
    daysvalid=$2
    shift 2
fi

call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.user }}"
    echo "debug: called as root, using $call_prefix"
fi

# main
cd "{{ settings.cert_dir }}/easyrsa"
randpass=$(openssl rand -base64 $randbytes | cut -c -$base64size)
randspellout=$(echo "$randpass" | fold -w 4 | tr "\n" " ")

# create cert
echo -e "$randpass\n$randpass" | \
    $call_prefix ./easyrsa --batch --passout=stdin --days="$daysvalid" \
        --req-cn="$certname" \
        --subject-alt-name="email:$email" \
        --req-org="{{ settings.domain }} Client Cert CA" \
        build-client-full "$certname"

# export/convert cert to p12 filetype (readable by almost all browser)
echo -e "$randpass\n$randpass\n$randpass\n$randpass" | \
    $call_prefix ./easyrsa --batch --passin=stdin --passout=stdin \
        export-p12 "$certname"

# update revocation list
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.user }}" -g "{{ settings.group }}" -m "0640" -T \
        "{{ settings.cert_dir }}/easyrsa/pki/crl.pem" \
        "{{ settings.cert_dir }}/{{ settings.ssl_client_crl }}"

# display password for user
cat << EOF
--------------------------------------------------------------------------
for decryption use: $randpass
for better spellout: $randspellout
--------------------------------------------------------------------------
EOF
randpass=""
randspellout=""

echo "sending cert to $email"
$call_prefix swaks -n --no-hints --to "$email" --header "Subject: Certificate $certname" --body "the client certificate is in the attachment" --attach-type "application/x-pkcs12" --attach-name "$certname.p12" --attach "{{ settings.cert_dir }}/easyrsa/pki/private/$certname.p12"
