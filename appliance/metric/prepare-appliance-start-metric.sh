#!/bin/bash

. /usr/local/share/appliance/env.functions.sh
. /usr/local/share/appliance/appliance.functions.sh

prepare_metric() {
    # set/clear flags and start/stop services connected to flags
    services="cadvisor.service node-exporter.service postgres_exporter.service process-exporter.service"
    if is_truestr "$APPLIANCE_METRIC_EXPORTER"; then
        flag_and_service_enable "metric.exporter" "$services"
    else
        flag_and_service_disable "metric.exporter" "$services"
    fi
    services="prometheus.service alertmanager.service"
    if is_truestr "$APPLIANCE_METRIC_SERVER"; then
        flag_and_service_enable "metric.server" "$services"
        sed -ri.bak  's/([ \t]+site:).*/\1 "'${APPLIANCE_DOMAIN}'"/g' /app/etc/prometheus.yml
        if ! diff -q /app/etc/prometheus.yml /app/etc/prometheus.yml.bak; then
            echo "info: changed prometheus external:site tag to ${APPLIANCE_DOMAIN}"
            systemctl restart prometheus.service
        fi
    else
        flag_and_service_disable "metric.server" "$services"
    fi
    if is_truestr "$APPLIANCE_METRIC_GUI"; then
        flag_and_service_enable "metric.gui" "grafana.service"
    else
        flag_and_service_disable "metric.gui" "grafana.service"
    fi
}

userdata_to_env appliance
prepare_metric
