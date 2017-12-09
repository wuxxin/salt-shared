#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh
. /usr/local/share/appliance/backup.functions.sh

userdata_to_env appliance

backup_hook prefix_config
create_backup_config
backup_hook postfix_config
