#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh
. /usr/local/share/appliance/update.functions.sh

userdata_to_env appliance

check_system_update
check_letsencrypt_update
check_compose_update
check_postgres_update
check_docker_update
