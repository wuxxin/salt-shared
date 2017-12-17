#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/metric.functions.sh

userdata_to_env appliance || exit $?

check_letsencrypt_update() {
    local domain RENEW_DAYS valid_until new_metric cert_metric
    local letsencrypt_need_update=false
    local letsencrypt_forced=false
    
    if test -e /app/etc/flags/force.update.zentyal-letsencrypt; then 
        letsencrypt_need_update=true
        letsencrypt_forced=true
    fi

    RENEW_DAYS="30"
    cert_metric=""
    
    for domain in $(cat /app/etc/dehydrated/domains.txt | sed -r "s/([^ ]+).*/\1/g"); do
        cert_file=/app/etc/dehydrated/certs/$domain/cert.pem
        valid_until=$(openssl x509 -in $cert_file -enddate -noout | sed -r "s/notAfter=(.*)/\1/g")
        openssl x509 -in $cert_file -checkend $((RENEW_DAYS * 86400)) -noout
        if test $? -ne 0; then
            letsencrypt_need_update=true
            echo "# Information: Letsencrypt certificate for $domain needs renewal (valid until $valid_until)"
        fi
        new_metric=$(mk_metric letsencrypt_valid_until gauge "timestamp-epoch-seconds of certificate validity end date" $(date --date="$valid_until" +%s) "domain=\"$domain\""; printf "\n")
        cert_metric="$cert_metric
$new_metric"
    done
    metric_export letsencrypt_valid_until "$cert_metric"

    echo "zentyal-letsencrypt:do_letsencrypt_update=$($letsencrypt_need_update && echo true || echo false)"
    if $letsencrypt_need_update; then 
        echo "$restart_str"
    fi
}

check_letsencrypt_update
