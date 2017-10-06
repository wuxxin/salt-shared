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
    if is_truestr "$APPLIANCE_METRIC_PGHERO"; then
        flag_and_service_enable "metric.pghero" "pghero-container.service"
    else
        flag_and_service_disable "metric.pghero" "pghero-container.service"
    fi
}

mute_alerts() {
    # JobInstanceDown
    # POST http://localhost:9093/api/v1/silences
    # application/json
    # {"matchers":[{"name":"alertname","value":"JobInstanceDown","isRegex":false}],"createdBy":"appliance-update@localhost","startsAt":"2017-02-19T14:01:00.000Z","endsAt":"2017-02-19T18:01:00.000Z","comment":"system update"}
    # response: json
    # {"status":"success","data":{"silenceId":"1e452199-cabc-47d7-a84e-a5acc0b8855f"}}
    # check status, and write silenceId to /app/etc/tags/silenceId
    #
    # get alert manager compatible datetime: $(date -u "+%Y-%m-%dT%H:%M:%SZ")
    # get seconds since epoch: $(date +%s)
    # add 30 minutes to epoch: $(( $(date +%s) + 60*30 ))
    # convert epoch to alert manager compatible datetime:
    # $(date --date="@$epochstring" -u "+%Y-%m-%dT%H:%M:%SZ")
    true
}

unmute_alerts() {
    # get silenceId from /app/etc/tags/silenceId or noop
    # DELETE
    # http://localhost:9093/api/v1/silence/1e452199-cabc-47d7-a84e-a5acc0b8855f
    true
}


mk_metric() {
    local metric value_type helptext value labels timestamp
    if test "$1" = ""; then
        cat <<"EOF"
$0 $1=metric, $2=value_type, $3=helptext, $4=value[, $5=labels{,}[, $6=timestamp-epoch-milliseconds]]
$2=value_type can be one of "counter, gauge, untyped"
$4=value float but can have "Nan", "+Inf", and "-Inf" as valid values
$5=labels string [name="value"[,name="value"]*]?
$6=timestamp-epoch-milliseconds int64, optional, default is empty
   use eg. "$(date +%s)000" for now
EOF
        return
    fi
    metric="$1"
    value_type="$2"
    helptext="$3"
    value="$4"
    labels="$5"
    timestamp="$6"
    if test "$labels" != ""; then labels="{$labels}"; fi
    if test "$timestamp" != ""; then
        printf '# HELP %s %s\n# TYPE %s %s\n%s%s %s %s\n' \
            "$metric" "$helptext" \
            "$metric" "$value_type" \
            "$metric" "$labels" "$value" "$timestamp"
    else
        printf '# HELP %s %s\n# TYPE %s %s\n%s%s %s\n' \
            "$metric" "$helptext" \
            "$metric" "$value_type" \
            "$metric" "$labels" "$value"
    fi
}


metric_export() {
    # usage: $1= metric output name  $2..$x= metric data
    local metric outputname
    metric=$1
    outputname=/app/etc/metric_import/${metric}.temp
    shift
    printf "%s\n" "$1" > ${outputname}
    shift
    while test "$1" != ""; do
        printf "%s\n" "$1" >> ${outputname}
        shift
    done
    chown 1000:1000 ${outputname}
    mv ${outputname} $(dirname ${outputname})/${metric}.prom
}


simple_metric() {
    local data
    if test "$1" = ""; then
        cat <<"EOF"
see mk_metric for detailed usage

example:
simple_metric test_metric gauge "ecs and appliance version" 1 \
"appliance_git_rev=\"$(gosu app git -C /app/appliance rev-parse HEAD)\",\
appliance_git_branch=\"$(gosu app git -C /app/appliance rev-parse --abbrev-ref HEAD)\",\
ecs_git_rev=\"$(gosu app git -C /app/ecs rev-parse HEAD)\",\
ecs_git_branch=\"$(gosu app git -C /app/ecs rev-parse --abbrev-ref HEAD)\""
EOF
        return
    fi
    data=$(mk_metric "$@")
    metric_export "$1" "$data"
}
