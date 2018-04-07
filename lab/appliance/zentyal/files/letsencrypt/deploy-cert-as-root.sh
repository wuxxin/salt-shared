#!/bin/bash
. /usr/local/share/appliance/metric.functions.sh
simple_metric letsencrypt_last_update counter "timestamp-epoch-seconds since last update to letsencrypt" $(date +%s)
/usr/local/sbin/unchanged-cert-as-root.sh "$@"
doveadm reload
postfix reload
apache2ctl graceful
if test -e /var/lib/zentyal/tmp/nginx.pid; then
    nginx -c /var/lib/zentyal/conf/nginx.conf -s reload
fi
