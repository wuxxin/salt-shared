#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh
. /usr/local/share/appliance/postgresql.functions.sh

userdata_to_env appliance || exit $?

