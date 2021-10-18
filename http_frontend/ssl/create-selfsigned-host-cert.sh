#!/usr/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 [--is-valid] [--days <days>] -k <keyfile_target> -c <certfile_target> <domain> [<domains>*]

Creates a selfsigned host certificate.

+ calling $0 --is-valid ...
    will exit 0 if certificate exists and all domains are listed in the current certificate,
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

if test "$1" != "-k" -o "$3" != "-c" -o "$5" = ""; then usage; fi
key_path="$2"
cert_path="$4"
shift 4

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
if test "$check_only" = "true"; then
    # check if current existing cert has all domains listed on commandline inside the cert
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

template="/usr/share/ssl-cert/ssleay.cnf"
TMPFILE="$(mktemp)" || exit 1
TMPOUT="$(mktemp)"  || exit 1
trap "rm -f $TMPFILE $TMPOUT" EXIT
sed -e s#@HostName@#"$certname"# -e s#@SubjectAltName@#"$subjectAltName"# $template > $TMPFILE
if $call_prefix openssl req -config $TMPFILE -new -x509 -days $daysvalid -nodes -sha256 \
    -out "$cert_path" -keyout "$key_path" > $TMPOUT 2>&1
then
    echo Could not create certificate. Openssl output was: >&2
    cat $TMPOUT >&2
    exit 1
fi
chmod 644 "$cert_path"
chmod 640 "$key_path"
