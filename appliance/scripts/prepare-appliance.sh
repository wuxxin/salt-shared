#!/bin/bash
set -o pipefail
. /usr/local/share/appliance/appliance.functions.sh
flagdir=/app/etc/flags

if test "$APPLIANCE_DOMAIN" != "$(hostname -f)"; then
    # set hostname from env if different
    echo "setting hostname to $APPLIANCE_DOMAIN"
    hostnamectl set-hostname $APPLIANCE_DOMAIN
fi

if test "$APPLIANCE_FLAGS_ENABLED_LEN" != ""; then
    for i in $(seq 0 $(( $APPLIANCE_FLAGS_ENABLED_LEN -1 )) ); do
        fname="APPLIANCE_FLAGS_ENABLED_${i}"; fvalue="${!fname}"
        touch $flagdir/$fvalue
    done
fi
if test "$APPLIANCE_FLAGS_DISABLED_LEN" != ""; then
    for i in $(seq 0 $(( $APPLIANCE_FLAGS_DISABLED_LEN -1 )) ); do
        fname="APPLIANCE_FLAGS_DISABLED_${i}"; fvalue="${!fname}"
        if test -e $flagdir/$fvalue; then rm $flagdir/$fvalue; fi
    done
fi
        
appliance_status "Appliance Startup" "Starting up"
run_hook appliance-prepare startup
