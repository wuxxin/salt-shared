#!/bin/bash
set -o pipefail
. /usr/local/share/appliance/appliance.functions.sh

if test "$APPLIANCE_DOMAIN" != "$(hostname -f)"; then
    # set hostname from env if different
    echo "setting hostname to $APPLIANCE_DOMAIN"
    hostnamectl set-hostname $APPLIANCE_DOMAIN
fi

appliance_status "Appliance Startup" "Starting up"
run_hook appliance-prepare startup
