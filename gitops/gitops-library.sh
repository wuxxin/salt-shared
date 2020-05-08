#!/bin/bash

uplink_ip () {
    local default_iface default_cidr default_ip
    default_iface=$(cat /proc/net/route | \
        grep -E -m 1 "^[^[:space:]]+[[:space:]]+00000000" | \
        sed -r "s/^([^[:space:]]+).*/\1/g")
    default_cidr=$(ip addr show dev "$default_iface" | \
        grep -E -m 1 "^[[:space:]]+inet[[:space:]]" | \
        sed -r "s/^[[:space:]]+inet[[:space:]]+(.+)[[:space:]]+brd.*/\1/g")
    default_ip=$(echo "$default_cidr" | sed -E "s#^([^/]+)/.*#\1#g")
    echo "$default_ip"
}

version_gt () {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

yaml2json () {
    python3 -c "import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, sort_keys=True)"
}

yaml_dict_get () {
    python3 -c "import sys, yaml, functools; print(functools.reduce(dict.__getitem__, sys.argv[1:], yaml.safe_load(sys.stdin)))" $@
}

json2yaml () {
    python3 -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)"
}

json_dict_get () {
    python3 -c "import sys, json, functools; print(functools.reduce(dict.__getitem__, sys.argv[1:], json.load(sys.stdin)))" $@
}

systemd_json_status () {
    systemctl status -l -q --no-pager -n 15 "$@" | text2json_status
}

text2json_status () {
    python3 -c "import sys, json; d={\"status\": sys.stdin.read().split(\"\n\")}; json.dump(d, sys.stdout)"
}

is_truestr () {
    test "$(printf "%s" "$1" | tr A-Z a-z)" = "true"
}

is_falsestr () {
    test "$(printf "%s" "$1" | tr A-Z a-z)" != "true"
}

install_as_user(){
    install -o "{{ settings.user }}" -g "{{ settings.user }}" "$@"
}

chown_to_user () {
    if test "$(id -u)" = "0"; then
        # if currently root, set owner to {{ settings.user }}
        chown "{{ settings.user }}:{{ settings.user }}" "$1"
    fi
}


# ### flags ###
set_flag () { # flagname
    touch "{{ settings.var_dir }}/flags/$1"
    chown_to_user "{{ settings.var_dir }}/flags/$1"
}

del_flag () { # flagname
    if test -e "{{ settings.var_dir }}/flags/$1"; then
        rm "{{ settings.var_dir }}/flags/$1"
    fi
}

flag_is_set () { # flagname
    if test -e "{{ settings.var_dir }}/flags/$1"; then
        return 0
    else
        return 1
    fi
}

set_flag_and_service_enable () { # flagname
    set_flag "$1"; systemctl start "$2"
}

del_flag_and_service_disable () { # flagname
    del_flag "$1"; systemctl stop "$2"
}


# ### tags ###
get_tag () { # tagname default
    cat "{{ settings.var_dir }}/tags/$1" 2> /dev/null || echo "$2"
}

get_tag_fullpath () { # tagname
    echo "{{ settings.var_dir }}/tags/$1"
}

del_tag () { # tagname
    if test -e "{{ settings.var_dir }}/tags/$1"; then
        rm "{{ settings.var_dir }}/tags/$1"
    fi
}

set_tag () { # tagname tagvalue
    echo "$2" > "{{ settings.var_dir }}/tags/$1"
    chown_to_user "{{ settings.var_dir }}/tags/$1"
}

set_tag_from_file () { # tagname filename
    install -o "{{ settings.user }}" -g "{{ settings.user }}" \
        "$2" "{{ settings.var_dir }}/tags/$1"
}


# ### metrics ###
mk_metric() {
    local metric value_type helptext value labels timestamp
    metric="$1"; value_type="$2"; helptext="$3"; value="$4"; labels="$5"; timestamp="$6"
    if test "$1" = ""; then
        cat <<"EOF"
$0 $1=metric $2=value_type $3=helptext $4=value [$5=labels{,} [$6=timestamp-epoch-ms]]
$2=value_type can be one of "counter, gauge, untyped"
$4=value float but can have "Nan", "+Inf", and "-Inf" as valid values
$5=labels string [name="value"[,name="value"]*]?
$6=timestamp-epoch-ms int64, optional, default is empty, use "$(date +%s)000" for now
EOF
        return
    fi
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

metric_save() {
    # usage: $1= metric output name  $2..$x= metric data
    local metric outputname
    metric="$1"
    shift
    outputname="{{ settings.var_dir }}/metrics/${metric}.temp"
    printf "%s\n" "$1" > "${outputname}"
    shift
    while test "$1" != ""; do
        printf "%s\n" "$1" >> "${outputname}"
        shift
    done
    chown_to_user "$outputname"
    mv "${outputname}" "$(dirname "${outputname}")/${metric}.prom"
}

metric_pipe_save() {
    # usage: $1= metric output name  STDIN= metric data
    local metric outputname
    metric="$1"
    outputname="{{ settings.var_dir }}/metrics/${metric}.temp"
    cat - > "${outputname}"
    chown_to_user "$outputname"
    mv "${outputname}" "$(dirname "${outputname}")/${metric}.prom"
}

simple_metric() {
    local data
    if test "$1" = ""; then
        cat <<"EOF"
see mk_metric for detailed usage; example:
simple_metric test_metric gauge "app version" 1 \
    "app_git_rev=\"$(gosu {{ settings.user }} git -C /app/origin rev-parse HEAD)\",\
    app_git_branch=\"$(gosu {{ settings.user }} git -C /app/origin rev-parse --abbrev-ref HEAD)\""
EOF
        return
    fi
    data=$(mk_metric "$@")
    metric_save "$1" "$data"
}


# ### error reporting ###
sentry_entry () {
    # call with (topic,message,[level,[extra]]) , default level=error, extra={}
    local topic=$1
    local msg=$2
    local level=${3:-error}
    local extra=${4:-\{\}}
    local gitops_rev=$(cat "{{ settings.src_dir }}/GIT_REV" 2> /dev/null || echo "invalid")
    local gitops_staging_rev=$(cat "{{ settings.staging_dir }}/GIT_REV" 2> /dev/null || echo "invalid")
    local gitops_current_rev=$(get_tag gitops_current_rev "invalid")
    local gitops_saltcall_rev=$(get_tag gitops_saltcall_rev "invalid")
    local gitops_database_rev=$(get_tag gitops_database_rev "invalid")
    local gitops_database_migrate_rev=$(get_tag gitops_database_migrate_rev "invalid")
    local gitops_failed_rev=$(get_tag gitops_failed_rev "invalid")
    local sentrycat="/usr/local/bin/sentrycat.py"

    if test "$gitops_current_rev" = "invalid"; then
        for i in $gitops_database_migrate_rev $gitops_database_rev $gitops_run_rev $gitops_staging_rev $gitops_saltcall_rev; do
            if test "$i" != "invalid"; then gitops_current_rev=$i; break; fi
        done
    fi

    local tags="{\"topic\": \"$topic\", \
        \"gitops_run_rev\": \"$gitops_run_rev\", \
        \"gitops_staging_rev\": \"$gitops_staging_rev\", \
        \"gitops_current_rev\": \"$gitops_current_rev\", \
        \"gitops_saltcall_rev\": \"$gitops_saltcall_rev\", \
        \"gitops_database_rev\": \"$gitops_database_rev\", \
        \"gitops_database_migrate_rev\": \"$gitops_database_migrate_rev\", \
        \"gitops_failed_rev\": \"$gitops_failed_rev\" \
        }"

    printf "Sentry Entry: Level: %s Topic: %s Message: %s Extra: %s" "$level" "$topic" "$msg" "$extra" 1>&2

    if test -n "SENTRY_DSN" -a -e "$sentrycat"; then
        SENTRY_DSN="$SENTRY_DSN" "$sentrycat" \
            --release "$gitops_current_rev" \
            --logger app.status \
            --level "$level" \
            --culprit "${UNITNAME:-shellscript}" \
            --server_name "$DOMAIN"  \
            --tags "$tags" \
            --extra "$extra" \
            "$msg"
    else
        echo "Warning: skipped sentry sending, missing SENTRY_DSN or sentrycat.py" 1>&2
    fi
}


# ### gitops maintenance ###
gitops_maintenance () {
    # call(Topic, Text)
    # or call("--clear") to delete maintenance file and let frontend serve application
    local templatefile="{{ settings.maintenance_template }}"
    local resultfile="{{ settings.maintenance_target }}"
    local topic text
    if test "$1" = "--clear"; then
        if test -e "$resultfile"; then
            rm -f "$resultfile"
            sentry_entry "Gitops Execution" "Frontend Ready" "info"
        fi
    else
        topic="$(printf "%s" "$1" | xmlstarlet esc)"
        text="$(printf "%s" "$2" | xmlstarlet esc)"
        echo "INFO: gitops status: $topic : $text"
        /usr/local/bin/jinja2 -D topic="$topic" -D text="$text" "$templatefile"  > "$resultfile"
        chown_to_user "$resultfile"
    fi
}

gitops_error()
{
    gitops_maintenance "$1" "$2"
    sentry_entry "$1" "$2" "$3" "$4"
}

gitops_failed()
{
    gitops_maintenance "$1" "$2"
    sentry_entry "$1" "$2" critical "$4"
    set_flag gitops_failed
}
