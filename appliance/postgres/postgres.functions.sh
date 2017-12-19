prepare_database () {
    gosu postgres pg_isready --timeout=10
    if test $? -ne 0; then
        appliance_failed "Appliance Standby" "Appliance is in standby, postgresql is not ready after 10 seconds"
    fi
    # check if ecs database exists
    gosu postgres psql -lqt | cut -d \| -f 1 | grep -qw "$ECS_DATABASE"
    if test $? -ne 0; then
        appliance_failed "Appliance Standby" "Appliance is in standby, no postgresql database named $ECS_DATABASE"
    fi
    if ! $(gosu postgres psql -c "\dg;" | grep app -q); then
        # create role app
        gosu postgres createuser app
    fi
    owner=$(gosu postgres psql -qtc "\l" |
        grep "^[ \t]*${ECS_DATABASE}" | sed -r "s/[^|]+\| +([^| ]+) +\|.*/\1/")
    if test "$owner" != "app"; then
        # set owner of ECS_DATABASE to app
        gosu postgres psql -c "ALTER DATABASE ${ECS_DATABASE} OWNER TO app;"
    fi
    if ! $(gosu postgres psql ${ECS_DATABASE} -qtc "\dx" | grep -q pg_stat_statements); then
        # create pg_stat_statements extension
        gosu postgres psql ${ECS_DATABASE} -c "CREATE extension pg_stat_statements;"
    fi
    pgpass=$(cat /app/etc/postgres_url.env 2> /dev/null | grep 'DATABASE_URL=' | \
        sed -re 's/DATABASE_URL=postgres:\/\/[^:]+:([^@]+)@.+/\1/g')
    if test "$pgpass" = ""; then pgpass="invalid"; fi
    if test "$pgpass" = "invalid"; then
        # set app user postgresql password to a random string and write to service_urls.env
        pgpass=$(HOME=/root openssl rand -hex 8)
        gosu postgres psql -c "ALTER ROLE app WITH ENCRYPTED PASSWORD '"${pgpass}"';"
        sed -ri "s/(postgres:\/\/app:)[^@]+(@[^\/]+\/).+/\1${pgpass}\2${ECS_DATABASE}/g" /app/etc/ecs/database_url.env
        # DATABASE_URL=postgres://app:invalidpassword@1.2.3.4:5432/ecs
    fi
}


check_postgres_update(){
    local postgres_list postgres_old postgres_new
    local postgres_need_update=false
    local postgres_forced=false

    if test -e /app/etc/flags/force.update.postgres; then 
        postgres_need_update=true
        postgres_forced=true
    fi
    
    # XXX needs up to date package list for proper results
    postgres_list=$(apt-cache policy postgresql-9.5 -q | grep -E "(Installed|Candidate)")
    postgres_old=$(printf "%s" "$postgres_list" | grep "Installed" | sed -r "s/.*Installed: ([^ ]+).*/\1/")
    postgres_new=$(printf "%s" "$postgres_list" | grep "Candidate" | sed -r "s/.*Candidate: ([^ ]+).*/\1/")
    if test "$postgres_old" != "$postgres_new"; then
        postgres_need_update=true
    fi
  
    echo "appliance:do_postgres_update=$($postgres_need_update && echo true || echo false)"
    if $postgres_need_update; then
        echo "# information postgres update: forced: $postgres_forced , current: $postgres_old , new: $postgres_new"
        echo "$restart_str"
    fi
}


do_postgres_update() {
    if $1 != "true"; then echo "# Warning: skipping $0, because of param $1"; return; fi
    simple_metric postgres_last_update counter "timestamp-epoch-seconds since last update to postgres" $start_epoch_seconds
    if test -e /app/etc/flags/force.update.postgres; then
        rm /app/etc/flags/force.update.postgres
    fi
    echo "Warning: prepare postgres update, kill all postgres connections to ecs except ourself"
    gosu app psql ecs -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'ecs' AND pid <> pg_backend_pid();"
}

