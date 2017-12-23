#!/bin/bash
set -o pipefail
. /usr/local/share/appliance/appliance.functions.sh

if test "$APPLIANCE_DOMAIN" != "$(hostname -f)"; then
    # set hostname from env if different
    echo "setting hostname to $APPLIANCE_DOMAIN"
    hostnamectl set-hostname $APPLIANCE_DOMAIN
    shortid=$(hostname -f | sed -r "s/^([^.]+)\..*/\1/")
    intip="127\.0\.1\.1"
    if ! grep -E -q "^${intip}[[:space:]]+${APPLIANCE_DOMAIN}[[:space:]]+${shortid}" /etc/hosts; then
        grep -q "^${intip}" /etc/hosts && \
        sed --in-place=.bak -r "s/^(${intip}[ \t]+).*/\1${APPLIANCE_DOMAIN} ${shortid}/" /etc/hosts || \
        sed --in-place=.bak -r "$ a${intip}\t${APPLIANCE_DOMAIN} ${shortid}" /etc/hosts
    fi
    echo -n "${APPLIANCE_DOMAIN}" > /etc/salt/minion_id
fi

if test "$APPLIANCE_FLAGS_ENABLED_LEN" != ""; then
    for i in $(seq 0 $(( $APPLIANCE_FLAGS_ENABLED_LEN -1 )) ); do
        fname="APPLIANCE_FLAGS_ENABLED_${i}"; fvalue="${!fname}"
        touch /app/etc/flags/$fvalue
    done
fi
if test "$APPLIANCE_FLAGS_DISABLED_LEN" != ""; then
    for i in $(seq 0 $(( $APPLIANCE_FLAGS_DISABLED_LEN -1 )) ); do
        fname="APPLIANCE_FLAGS_DISABLED_${i}"; fvalue="${!fname}"
        if test -e /app/etc/flags/$fvalue; then rm /app/etc/flags/$fvalue; fi
    done
fi
        
appliance_status "Appliance Startup" "Starting up"
run_hook appliance-prepare start
