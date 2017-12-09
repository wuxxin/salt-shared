#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh

prepare_metric() {
    # start/stop services connected to flags
    services="$APPLIANCE_METRIC_METRIC_EXPORTER"
    if test -e /app/etc/flags/metric.exporter; then
        systemctl start $services
    else
        systemctl stop $services
    fi
    
    services="$APPLIANCE_METRIC_METRIC_SERVER"
    if test -e /app/etc/flags/metric.server; then
        systemctl start $services
        sed -ri.bak  's/([ \t]+site:).*/\1 "'${APPLIANCE_DOMAIN}'"/g' /app/etc/prometheus.yml
        if ! diff -q /app/etc/prometheus.yml /app/etc/prometheus.yml.bak; then
            echo "info: changed prometheus external:site tag to ${APPLIANCE_DOMAIN}"
            systemctl restart prometheus.service
        fi
    else
      systemctl stop $services
    fi
    
    services="$APPLIANCE_METRIC_METRIC_GUI"
    if test -e /app/etc/flags/metric.gui; then
        systemctl start $services
    else
        systemctl stop $services
    fi
}

userdata_to_env appliance
prepare_metric
