check_letsencrypt_update(){
    local RENEW_DAYS valid_until new_metric cert_metric
    local letsencrypt_need_update=false
    RENEW_DAYS="30"
    cert_metric=""
    for i in $(cat /app/etc/dehydrated/domains.txt | sed -r "s/([^ ]+).*/\1/g"); do
        cert_file=/app/etc/dehydrated/certs/$i/cert.pem
        valid_until=$(openssl x509 -in $cert_file -enddate -noout | sed -r "s/notAfter=(.*)/\1/g")
        openssl x509 -in $cert_file -checkend $((RENEW_DAYS * 86400)) -noout
        if test $? -ne 0; then
            letsencrypt_need_update=true
            echo "Information: Letsencrypt certificate for $i needs renewal (valid until $valid_until)"
        fi
        new_metric=$(mk_metric letsencrypt_valid_until gauge "timestamp-epoch-seconds of certificate validity end date" $(date --date="$valid_until" +%s) "domain=\"$i\""; printf "\n")
        cert_metric="$cert_metric
$new_metric"
    done
    metric_export letsencrypt_valid_until "$cert_metric"
    $letsencrypt_need_update
}
