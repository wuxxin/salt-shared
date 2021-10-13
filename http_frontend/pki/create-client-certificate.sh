#!/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage:  $0 [--days <number>] [--user <user-email@address.domain>] <cert_name> [--san <san-values>]

Creates a client certificate, optionally send created certificate via Email.

+ --days <number>
    specify a days valid value for the certificate. default is $daysvalid days

+ --user <user-email@adress.domain>
    a $(( randbytes *8 )) bits entropy base64 encoded password will be generated using
    `"openssl rand -base64 $randbytes"`
    and the target certificate will be send via email to the specified address,
    in an crossbrowser compatible password encrypted format,
    the password is printed to the console for further usage

+ --san <additional-san-values>
    + must be in a valid format accepted by openssl
    + san-value: (email|URI|DNS|RID|IP|dirName|otherName):<value>
    + additional-san-values: san-value(,additional-san-values)*
    + Examples
        + point to a webpage and an dns name
            --san "URI:https://web.domain.tl,DNS:web.domain.tl"
        + specify an emailaddress without a password or sending the certificate via email
            --san "email:name@address"
EOF
    exit 1
}

randbytes=15
base64size=$(echo "if (($randbytes * 8) > ($randbytes * 8 /6 *6)) { $randbytes * 8 /6 +1} else { $randbytes *8 /6 }" | bc)
daysvalid="{{ settings.ssl_local_ca_validity_days }}"
additional_san=""
email=""
call_prefix=""

if test "$1" = "--days" -a "$2" != ""; then daysvalid=$2; shift 2; fi
if test "$1" = "--user" -a "$2" != ""; then email="$2"; shift 2; fi
if test "$1" = ""; then usage; fi
certname="$1"
shift
if test "$1" = "--san" -a "$2" != ""; then
    additional_san=",$2"
fi
call_prefix=""
if test "$(id -u)" = "0"; then
    call_prefix="gosu {{ settings.ssl.user }}"
    echo "debug: called as root, using $call_prefix"
fi

# main
cd "{{ settings.ssl.base_dir }}/easyrsa"
if test "$email" = ""; then
    # create cert
    $call_prefix ./easyrsa --batch \
        --use-algo="{{ settings.ssl_local_ca_algo }}" --curve="{{ settings.ssl_local_ca_curve }}" \
        --days="$daysvalid" \
        --req-cn="$certname" \
        --subject-alt-name="${additional_san}" \
        --req-org="{{ settings.domain }} CA Client Cert" \
        build-client-full "$certname"
    # update revocation list
    $call_prefix ./easyrsa --batch gen-crl
    install -o "{{ settings.ssl.user }}" -g "{{ settings.ssl.user }}" -m "0640" -T \
            "{{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem" \
            "{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_crl }}"
    exit 0
fi

randpass=$(openssl rand -base64 $randbytes | cut -c -$base64size)
randspellout=$(echo "$randpass" | fold -w 4 | tr "\n" " ")

# create cert
echo -e "$randpass\n$randpass" | \
    $call_prefix ./easyrsa --batch --passout=stdin \
        --use-algo="{{ settings.ssl_local_ca_algo }}" --curve="{{ settings.ssl_local_ca_curve }}" \
        --days="$daysvalid" \
        --req-cn="$certname" \
        --subject-alt-name="email:$email${additional_san}" \
        --req-org="{{ settings.domain }} CA Client Cert" \
        build-client-full "$certname"

# export/convert cert to p12 filetype (readable by almost all browser)
echo -e "$randpass\n$randpass\n$randpass\n$randpass" | \
    $call_prefix ./easyrsa --batch --passin=stdin --passout=stdin \
        export-p12 "$certname"

# update revocation list
$call_prefix ./easyrsa --batch gen-crl
install -o "{{ settings.ssl.user }}" -g "{{ settings.ssl.user }}" -m "0640" -T \
        "{{ settings.ssl.base_dir }}/easyrsa/pki/crl.pem" \
        "{{ settings.ssl.base_dir }}/{{ settings.ssl_local_ca_crl }}"

# display password for user
cat << EOF
--------------------------------------------------------------------------
for copy/paste use: $randpass
for better spellout: $randspellout
--------------------------------------------------------------------------
EOF
randpass=""
randspellout=""

echo "sending cert to $email"
$call_prefix swaks -n --no-hints \
    --to "$email" \
    --header "Subject: Client Certificate $certname for $(hostname)" \
    --body "the p12 client certificate for $(hostname)" \
    --attach-type "application/x-pkcs12" \
    --attach-name "$certname.p12" \
    --attach "{{ settings.ssl.base_dir }}/easyrsa/pki/private/$certname.p12"
