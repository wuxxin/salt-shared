#!/bin/bash
set -o pipefail
. /usr/local/share/appliance/appliance.include
. /usr/local/share/appliance/prepare-storage.sh
. /usr/local/share/appliance/prepare-extra.sh
. /usr/local/share/appliance/prepare-postgresql.sh
. /usr/local/share/appliance/prepare-metric.sh
. /usr/local/share/appliance/prepare-backup.sh
. /usr/local/share/appliance/prepare-ssl.sh
. /usr/local/share/appliance/prepare-postfix.sh
. /usr/local/share/appliance/prepare-stunnel.sh
. /usr/local/share/appliance/prepare-nginx.sh
. /usr/local/share/appliance/prepare-update.sh

# ### Runtime Configuration
# Dependency order:
# + hostname
# + nginx start
# + prepare_storage
# ...
# + prepare_database (before other service starts, eg. metric, backup, ssl)
# ...
# + prepare_ssl (before postfix, stunnel and nginx, may change certs, service have to restart)
# ...
# + prepare_nginx

if test "$APPLIANCE_DOMAIN" != "$(hostname -f)"; then
    # set hostname from env if different
    echo "setting hostname to $APPLIANCE_DOMAIN"
    hostnamectl set-hostname $APPLIANCE_DOMAIN
fi

appliance_status "Appliance Startup" "Starting up"
systemctl enable nginx
systemctl start nginx
prepare_storage         # storage setup
prepare_storagevault    # storagevault gpg keys setup
prepare_extra_files     # write out extra files from env
prepare_extra_packages  # install extra packages if not already installed
prepare_postgresql      # postgresql tuning
prepare_database        # database setup
prepare_metric          # metric collection
prepare_backup          # backup setup
prepare_ssl             # ssl key,certs,dhparam setup
prepare_postfix         # postfix setup
prepare_stunnel         # stunnel setup
prepare_update          # update setup
prepare_nginx           # nginx setup
