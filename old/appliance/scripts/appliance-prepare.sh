#!/bin/bash
set -o pipefail
. /usr/local/share/appliance/appliance.functions.sh

if test "$APPLIANCE_DOMAIN" != "$(hostname -f)"; then
    # set hostname from env if different
    hostname="$APPLIANCE_DOMAIN"
    shortname="${hostname%%.*}"
    domainname="${hostname#*.}"
    intip="127\.0\.1\.1"
    
    echo "INFO: set fqdn and minion_id to $hostname"
    if ! grep -E -q "^${intip}[[:space:]]+${hostname}[[:space:]]+${shortname}" /etc/hosts; then
        grep -q "^${intip}" /etc/hosts && \
        sed --in-place=.bak -r "s/^(${intip}[ \t]+).*/\1${hostname} ${shortname}/" /etc/hosts || \
        sed --in-place=.bak -r "$ a${intip}\t${hostname} ${shortname}" /etc/hosts
        echo "INFO: Modified /etc/hosts"
    fi
    hostnamectl set-hostname $shortname
    hostname -f || (echo "error $? on hostname -f"; exit 1)
    
    echo -n "$hostname" > /etc/salt/minion_id
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
