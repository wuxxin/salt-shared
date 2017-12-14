#!/bin/bash
realpath=$(dirname $(readlink -e "$0"))
if test -e $realpath/env.functions.sh; then
    # we are called from the repository and not from a installed appliance, correct paths
    . $realpath/env.functions.sh
else
    . /usr/local/share/appliance/env.functions.sh
fi

if test -e /app/etc/flags/env_from_pillar; then
    userdata_yaml=$(ENV_YML=pillar get_userdata)
else
    userdata_yaml=$(get_userdata)
fi
if test $? -ne 0; then
    printf "Error reading userdata: %s\n" $(echo "$userdata_yaml"| grep USERDATA_ERR)
    exit 1
fi

printf "found user-data: %s\n" "$(printf "%s" "$userdata_yaml" | grep USERDATA_TYPE)"
printf "write userdata to /run/active-env.yml\n"
printf "%s" "$userdata_yaml" > /run/active-env.yml
chmod 0600 /run/active-env.yml
