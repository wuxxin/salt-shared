#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh
. /usr/local/share/appliance/metric.functions.sh
. /usr/local/share/appliance/update.functions.sh

userdata_to_env appliance || exit $?

# call with target_function [optargs]

if [[ "$1" =~ ^do_(appliance|compose|docker|system)_update$ ]]; then
    target="$1"
    shift
    $target "$@"
else
    echo "Error: wrong params, while executing $0: $@";
    exit 1
fi
