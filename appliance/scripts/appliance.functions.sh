#!/bin/bash

default_branch(){ echo $(cat /app/etc/tags/APPLIANCE_GIT_BRANCH || echo "") }
default_source(){ echo $(cat /app/etc/tags/APPLIANCE_GIT_SOURCE || echo "") }
running_source(){ echo $(gosu app git config --get remote.origin.url || echo "") }

if test $APPLIANCE_GIT_SOURCE = ""; then
    if test "$(default_source)" = ""; then
        APPLIANCE_GIT_SOURCE="$(running_source)"
    else
        APPLIANCE_GIT_SOURCE="$(default_source)"
    fi
fi
if test $APPLIANCE_GIT_BRANCH = ""; then
    if test "$(default_branch)" = ""; then
        APPLIANCE_GIT_BRANCH="master"
    else
        APPLIANCE_GIT_BRANCH="$(default_BRANCH)"
    fi
fi

run_hook()
{
    for script in $(find /app/etc/hooks/$1/$2/* -type f -executable | sort ); do
        # execute $script
        ENV_YML=/run/active-env.yml $script || (
          sentry_entry "Appliance Hook" "hook error $1-$2-$script" "error" "$(service_status $1.service)"
          exit 1
        )
    done
}

text2json(){
    python3 -c "import sys, json; \
    d={\"status\": sys.stdin.read().split(\"\n\")}; json.dump(d, sys.stdout)"
}

service_status(){
    systemctl status -l -q --no-pager -n 15 $@ | text2json
}

sentry_entry () {
    # call with (group,message,[level,[extra]]) , default level is error
    local group=$1
    local msg=$2
    local level=${3:-error}
    local extra=${4:-\{\}}
    local tags="{\"group\": \"$group\" }"

    printf "Level: %s Group: %s Message: %s Extra: %s" "$level" "$group" "$msg" "$extra"
    if test -n "$APPLIANCE_SENTRY_DSN"; then
        SENTRY_DSN="$APPLIANCE_SENTRY_DSN" /usr/local/bin/ravencat.py \
            --culprit ${UNITNAME:-shellscript} \
            --logger appliance.status \
            --release "$current_appliance" \
            --site "$APPLIANCE_DOMAIN"  \
            --level "$level" \
            --tags "$tags" \
            --extra "$extra" \
            "$msg"
    fi
}

appliance_status () {
    # call(Title, Text)
    # or call("--disable")
    local templatefile=/app/etc/app-template.html
    local resultfile=/var/www/html/503.html
    local title text
    if test "$1" = "--disable"; then
        if test -e $resultfile; then
            rm -f $resultfile
            sentry_entry "Appliance Running" "Appliance started" "info"
        fi
    else
        echo "INFO: appliance status: $1 : $2"
        title=$(echo "$1" | tr / \\/)
        text=$(echo "$2" | tr / \\/)
        # XXX will fail if $text includes "/" characters
        cat $templatefile |
            sed -r "s/\{\{ ?title ?\}\}/$title/g;s/\{\{ ?text ?\}\}/$text/g" > $resultfile
        if test "$(id -u)" = "0"; then
            # if currently root, set owner to app, so app can also override current status
            chown app:app $resultfile
        fi
    fi
}

appliance_exit()
{
    appliance_status "$1" "$2"
    sentry_entry "$1" "$2" "$3" "$4"
    exit 1
}

appliance_failed()
{
    appliance_status "$1" "$2"
    sentry_entry "$1" "$2" critical "$4"
    touch /run/appliance-failed
    exit 1
}

is_truestr () {
    test "$(printf "%s" "$1" | tr A-Z a-z)" = "true"
}

is_falsestr () {
    test "$(printf "%s" "$1" | tr A-Z a-z)" != "true"
}

default_route_interface_ip () {
    default_iface=$(awk '$2 == 00000000 { print $1 }' /proc/net/route)
    ip addr show dev "$default_iface" | awk '$1 == "inet" { sub("/.*", "", $2); print $2 }'
}
