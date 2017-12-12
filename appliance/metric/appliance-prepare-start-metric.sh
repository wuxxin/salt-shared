#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh

# XXX keep this list and the list in prometheus.sls in sync
exporter_list="cadvisor node-exporter process-exporter postgres_exporter"
server_list="prometheus alertmanager"
gui_list="grafana"

prepare_metric() {
    # start/stop services connected to flags
    local services
    local i
    
    services="${APPLIANCE_METRIC_EXPORTER_LIST:=$exporter_list}"
    for i in $services; do
        if test -e /app/etc/flags/metric.exporter -a test ! -e /app/etc/flags/no.$i; then
            systemctl start $i
        else
            systemctl stop $i
        fi
    done
    
    services="${APPLIANCE_METRIC_SERVER_LIST:=$server_list}"
    for i in $services; do
        if test -e /app/etc/flags/metric.server -a test ! -e /app/etc/flags/no.$i; then
            systemctl start $i
            
            sed -ri.bak  's/([ \t]+site:).*/\1 "'${APPLIANCE_DOMAIN}'"/g' /app/etc/prometheus.yml
            if ! diff -q /app/etc/prometheus.yml /app/etc/prometheus.yml.bak; then
                echo "info: changed prometheus external:site tag to ${APPLIANCE_DOMAIN}"
                systemctl restart prometheus.service
            fi
        else
            systemctl stop $services
        fi
    done
    
    services="${APPLIANCE_METRIC_GUI_LIST:=$gui_list}"
    for i in $services; do
        if test -e /app/etc/flags/metric.gui -a test ! -e /app/etc/flags/no.$i; then
            systemctl start $i
        else
            systemctl stop $i
        fi
    done
}

userdata_to_env appliance
prepare_metric
