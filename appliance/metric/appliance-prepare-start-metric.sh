#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh

prepare_metric() {
    # start/stop services connected to flags
    services="cadvisor.service node-exporter.service postgres_exporter.service process-exporter.service"
    if test -e /app/etc/flags/metric.exporter; then
        systemctl start $services
    else
        systemctl stop $services
    fi
    
    services="prometheus.service alertmanager.service"
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
    
    if test -e /app/etc/flags/metric.gui; then
        systemctl start "grafana.service"
    else
        systemctl stop "grafana.service"
    fi
}

userdata_to_env appliance
prepare_metric
