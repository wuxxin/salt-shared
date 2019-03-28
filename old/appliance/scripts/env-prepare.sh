#!/bin/bash
. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh

# ### environment setup, read userdata
if test -e /app/etc/flags/env_from_pillar; then
    userdata_yaml=$(ENV_YML=pillar get_userdata)
else
    userdata_yaml=$(get_userdata)
fi
if test $? -ne 0; then
    appliance_exit "Appliance Error" "$(printf "Error reading userdata: %s" $(echo \"$userdata_yaml\" | grep USERDATA_ERR))"
fi
printf "found user-data: %s\n" "$(printf "%s" "$userdata_yaml" | grep USERDATA_TYPE)"
printf "write userdata to /run/active-env.yml\n"
printf "%s" "$userdata_yaml" > /run/active-env.yml
chmod 0600 /run/active-env.yml

# test: export active yaml into environment
ENV_YML=/run/active-env.yml userdata_to_env appliance
if test $? -ne 0; then
    appliance_exit "Appliance Error" "Could not activate userdata environment"
fi

# check if standby is true
if is_truestr "$APPLIANCE_STANDBY"; then
    appliance_exit "Appliance Standby" "Appliance is in standby" "debug"
fi
