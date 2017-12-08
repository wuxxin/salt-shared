#!/bin/bash
set -o pipefail
. /usr/local/share/appliance/appliance.functions.sh

if test "$APPLIANCE_DOMAIN" != "$(hostname -f)"; then
    # set hostname from env if different
    echo "setting hostname to $APPLIANCE_DOMAIN"
    hostnamectl set-hostname $APPLIANCE_DOMAIN
fi

if test "$APPLIANCE_FLAGS_LEN" != ""; then
    for i in $(seq 0 $(( $APPLIANCE_FLAGS_LEN -1 )) ); do
        fieldname="APPLIANCE_FLAGS_${i}"; fname="${!fieldname}"
        touch /app/etc/flags/$fname
    done
fi
        
appliance_status "Appliance Startup" "Starting up"
run_hook appliance-prepare startup
