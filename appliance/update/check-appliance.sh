#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh
. /usr/local/share/appliance/metric.functions.sh
. /usr/local/share/appliance/update.functions.sh

userdata_to_env appliance || exit $?

check_compose_update
check_docker_update
check_postgres_update
check_system_update
