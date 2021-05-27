#!/bin/bash
set -eo pipefail
# set -x

. /usr/local/lib/gitops-library.sh

usage() {
    cat << EOF
Usage: $0 <certificate.pem> <days-warning> <days-error>

- if certificate does not exist
    - print error, exit 1
- write metric entry of certificates validity end date
- if cert no longer valid
    - print error, exit 1
- if validity <= days-error
    - print error, make sentry error entry, exit 0
- if validity <= days-warning
    - print warning, make sentry warning entry, exit 0
EOF
    exit 1
}

check_validity() { # $1=days $2=issue(warning,error)
    local min_days issue res
    min_days=$1
    issue=$2
    openssl x509 -in "$certfile" -checkend $((min_days * 86400)) -noout > /dev/null && res=$? || res=$?
    if test $res -ne 0; then
        echo "${issue}: SSL certificate is less than $min_days days valid (until $valid_until)"
        sentry_entry "$issue" "SSL ${issue}" \
            "Certificate for $subject_cn is less than $min_days days valid\nValidity end date=$valid_until"
    fi
    return $res
}

if test ! -e "$1"; then echo "Error: $1 does not exist"; usage; fi
if test "$3" = ""; then usage; fi

certfile="$1"
warning_days="$2"
error_days="$3"
valid_until=$(openssl x509 -in "$certfile" -enddate -noout | sed -r 's/notAfter=(.*)/\1/g')
subject_cn=$(openssl x509 -text -noout -in "$certfile" \
            | grep -E "Subject:.+CN" | sed -r 's/[[:space:]]+Subject:.+CN += +(.+)/\1/g')

simple_metric ssl_cert_valid_until gauge \
    "timestamp of certificate validity end date" \
    "$(date --date="$valid_until" +%s)000" "domain=\"$subject_cn\""

if test "$(date --date="$valid_until" +%s)" -le "$(date +%s)"; then
    echo "error: SSL certificate is expired at $valid_until"
    exit 1
fi
check_validity "$error_days" error && res=$? || res=$?
# dont warn if already an error
if test $res -eq 0; then
    check_validity "$warning_days" warning && res=$? || res=$?
fi
