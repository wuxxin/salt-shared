#!/usr/bin/bash

uplink_ip() {
    local default_iface default_ip
    default_iface=$(ip -j route list default | sed -r 's/.+dev":"([^"]+)".+/\1/g')
    default_ip=$(ip -j addr show $default_iface | sed -r 's/.+"inet","local":"([^"]+)",.+/\1/g')
    echo "$default_ip"
}

version_gt() { # $1=version $2=version
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

json2yaml() { # filter pipe
    python3 -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)"
}

yaml2json() { # filter pipe
    python3 -c "import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, sort_keys=True)"
}

text2json() { # $1=dictvarname, STDIN=text , return STDOUT=json dict {'varname': [text.split] }
    python3 -c "import sys, json; d={\"$1\": sys.stdin.read().split(\"\n\")}; json.dump(d, sys.stdout)"
}

json_dict_get() { # $1=entry [$2..$x=subentry] , eg. gitops git source
    python3 -c "import sys, json, functools; print(functools.reduce(dict.__getitem__, sys.argv[1:], json.load(sys.stdin)))" $@
}

yaml_dict_get() { # $1=entry [$2..$x=subentry] , eg. gitops git source
    python3 -c "import sys, yaml, functools; print(functools.reduce(dict.__getitem__, sys.argv[1:], yaml.safe_load(sys.stdin)))" $@
}

unit_json_status() { # $UNITNAME
    status=$(systemctl status -l -q --no-pager -n 0 "$UNITNAME"| text2json status)
    log=$(journalctl -l -q --no-pager -n 15 -u "$UNITNAME" | text2json log)
    printf "%s\n%s" "$status" "$log" | jq -s '.[0] + .[1]'
}

is_truestr() { # $1=boolstring , return true if lower($1) = "true"
    test "$(printf "%s" "$1" | tr A-Z a-z)" = "true"
}

is_falsestr() { # $1=boolstring , return true if lower($1) != "true"
    test "$(printf "%s" "$1" | tr A-Z a-z)" != "true"
}

install_as_user() { # $1..$x= parameter for install
    install -o "{{ settings.user }}" -g "{{ settings.user }}" "$@"
}

chown_to_user() { # $1=filename
    if test "$(id -u)" = "0"; then
        # if currently root, set owner to {{ settings.user }}
        chown "{{ settings.user }}:{{ settings.user }}" "$1"
    fi
}


# ### flags ###
set_flag() { # $1=flagname
    touch "{{ settings.var_dir }}/flags/$1"
    chown_to_user "{{ settings.var_dir }}/flags/$1"
}

del_flag() { # $1=flagname
    if test -e "{{ settings.var_dir }}/flags/$1"; then
        rm "{{ settings.var_dir }}/flags/$1"
    fi
}

flag_is_set() { # $1=flagname
    if test -e "{{ settings.var_dir }}/flags/$1"; then
        return 0
    else
        return 1
    fi
}

set_flag_and_service_enable() { # $1=flagname
    set_flag "$1"; systemctl start "$2"
}

del_flag_and_service_disable() { # $1=flagname
    del_flag "$1"; systemctl stop "$2"
}


# ### tags ###
get_tag() { # $1=tagname $2=default if not found
    cat "{{ settings.var_dir }}/tags/$1" 2> /dev/null || echo "$2"
}

get_tag_fullpath() { # $1=tagname
    echo "{{ settings.var_dir }}/tags/$1"
}

del_tag() { # $1=tagname
    if test -e "{{ settings.var_dir }}/tags/$1"; then
        rm "{{ settings.var_dir }}/tags/$1"
    fi
}

set_tag() { # $1=tagname $2=tagvalue
    echo "$2" > "{{ settings.var_dir }}/tags/$1"
    chown_to_user "{{ settings.var_dir }}/tags/$1"
}

set_tag_from_file() { # $1=tagname $2=filename
    install -o "{{ settings.user }}" -g "{{ settings.user }}" \
        "$2" "{{ settings.var_dir }}/tags/$1"
}


# ### prometheus "prom" file format compatible metrics ###
mk_metric() { # $1=metric $2=value_type $3=helptext $4=value [$5=labels{,} [$6=timestamp-epoch-ms]]
    local metric value_type helptext value labels timestamp
    metric="$1"; value_type="$2"; helptext="$3"; value="$4"; labels="$5"; timestamp="$6"
    if test "$1" = ""; then
        cat << EOF
\$0 \$1=metric \$2=value_type \$3=helptext \$4=value [\$5=labels{,} [\$6=timestamp-epoch-ms]]
\$2=value_type can be one of "counter, gauge, untyped"
\$4=value float but can have "Nan", "+Inf", and "-Inf" as valid values
\$5=labels string [name="value"[,name="value"]*]?
\$6=timestamp-epoch-ms int64, optional, default is empty, use "\$(date +%s)000" for now
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

metric_save() { # $1=metric-output-name $2..$x=metric data
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

metric_pipe_save() { # $1=metric-output-name STDIN=metric-data
    local metric outputname
    metric="$1"
    outputname="{{ settings.var_dir }}/metrics/${metric}.temp"
    cat - > "${outputname}"
    chown_to_user "$outputname"
    mv "${outputname}" "$(dirname "${outputname}")/${metric}.prom"
}

simple_metric() { # equal to mk_metric, but saves/overwrites data to filename=$1
    local data
    if test "$1" = ""; then
        cat <<"EOF"
see mk_metric for detailed usage; writes one metric per file. example:
simple_metric test_metric gauge "app version" 1 \
    "app_git_rev=\"$(gosu {{ settings.user }} git -C /app/origin rev-parse HEAD)\",\
    app_git_branch=\"$(gosu {{ settings.user }} git -C /app/origin rev-parse --abbrev-ref HEAD)\""
EOF
        return
    fi
    data=$(mk_metric "$@")
    metric_save "$1" "$data"
}


# ### sentry error reporting ###
sentry_entry() { # $1=level $2=topic $3=message [$4=extra={} [$5=logger=app-status]]] ENV[UNITNAME]=culprit
    local topic msg level culprit extra logger tags
    local gitops_run_rev gitops_current_rev gitops_failed_rev sentrycat

    level=${1}; topic=$2; msg=$3; extra=${4:-\{\}}; logger=${5:-app.status}
    culprit=${UNITNAME:-shellscript}
    gitops_run_rev=$(cat "{{ settings.src_dir }}/.git/refs/heads/{{ settings.git.branch }}" 2> /dev/null || echo "invalid")
    gitops_current_rev=$(get_tag gitops_current_rev "$gitops_run_rev")
    gitops_failed_rev=$(get_tag gitops_failed_rev "invalid")
    gitops_sentry_dsn="{{ settings.sentry.dsn|d('') }}"
    sentrycat="/usr/local/bin/sentrycat.py"
    if test -n "$SENTRY_DSN"; then gitops_sentry_dsn="$SENTRY_DSN"; fi

    tags="{\"topic\": \"$topic\", \
        \"gitops_run_rev\": \"$gitops_run_rev\", \
        \"gitops_current_rev\": \"$gitops_current_rev\", \
        \"gitops_failed_rev\": \"$gitops_failed_rev\" \
        }"

    printf "Sentry Entry: Level: %s Topic: '%s' Culprit: '%s' Message: '%s' Logger: '%s' Extra: '%s'" "$level" "$topic" "$culprit" "$msg" "$logger" "$extra" 1>&2

    if test -n "gitops_sentry_dsn" -a -e "$sentrycat"; then
        SENTRY_DSN="$gitops_sentry_dsn" "$sentrycat" \
            --release "$gitops_current_rev" \
            --logger "$logger" \
            --level "$level" \
            --culprit "$culprit" \
            --server_name "${DOMAIN:-$(hostname -f)}"  \
            --tags "$tags" \
            --extra "$extra" \
            "$msg"
    else
        echo "Warning: skipped sentry sending, missing SENTRY_DSN or sentrycat.py" 1>&2
    fi
}


# ### gitops maintenance ###
gitops_maintenance() { # $1="--clear" | $1=topic $2=message
    # $1=--clear" to delete maintenance file and let frontend serve application
    local templatefile="{{ settings.maintenance_template }}"
    local resultfile="{{ settings.maintenance_target }}"
    local topic text
    if test "$1" = "--clear"; then
        if test -e "$resultfile"; then
            rm -f "$resultfile"
            sentry_entry info "Gitops Execution" "Frontend Ready"
        fi
    else
        topic="$(printf "%s" "$1" | xmlstarlet esc)"
        text="$(printf "%s" "$2" | xmlstarlet esc)"
        echo "INFO: gitops status: $topic : $text"
        /usr/local/bin/jinja2 -D topic="$topic" -D text="$text" "$templatefile"  > "$resultfile"
        chown_to_user "$resultfile"
    fi
}

gitops_error() { # $1=topic $2=message [$3=extra={} [$4=logger=app-status]]]
    gitops_maintenance "$1" "$(echo "$2" | head -n 1)"
    sentry_entry error "$1" "$2" "$3" "$4"
}

gitops_failed() { # $1=topic $2=message [$3=extra={} [$4=logger=app-status]]]
    gitops_maintenance "$1" "$(echo "$2" | head -n 1)"
    sentry_entry critical "$1" "$2" "$3" "$4"
    set_flag gitops.update.failed
}
