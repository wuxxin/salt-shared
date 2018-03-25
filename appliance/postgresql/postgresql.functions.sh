#!/bin/bash

prepare_postgresql_database () {

    local stub i fieldname uname upassword uoldpass 

    if test "$APPLIANCE_DATABASE_POSTGRESQL_DATABASE_LEN" = ""; then
        echo "Information: No Database entries for postgresql found"
        return
    fi
    
    gosu postgres pg_isready --timeout=10
    if test $? -ne 0; then
        appliance_failed "Appliance Standby" "Appliance is in standby, postgresql is not ready after 10 seconds"
    fi

    # check if user exists
    if test "$APPLIANCE_DATABASE_POSTGRESQL_USER_LEN" != ""; then
        stub="APPLIANCE_DATABASE_POSTGRESQL_USER"
        for i in $(seq 0 $(( $APPLIANCE_DATABASE_POSTGRESQL_USER_LEN -1 )) ); do
            fieldname="${stub}_${i}_NAME"; uname="${!fieldname}"
            fieldname="${stub}_${i}_PASSWORD"; upassword="${!fieldname}"
            if ! $(gosu postgres psql -c "\dg;" | grep $uname -q); then
                gosu postgres createuser $uname
            fi
            
            uoldpass=$(gosu postgres psql -q -t -c "select rolpassword from pg_authid where rolname = 'test';" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            if test "${upassword}" != "${uoldpass}"; then
                gosu postgres psql -c "ALTER ROLE $uname WITH ENCRYPTED PASSWORD '"${upassword}"';"
            fi
        done
    fi

    # for each database
    if test "$APPLIANCE_DATABASE_POSTGRESQL_DATABASE_LEN" != ""; then
        stub="APPLIANCE_DATABASE_POSTGRESQL_DATABASE"
        for i in $(seq 0 $(( $APPLIANCE_DATABASE_POSTGRESQL_DATABASE_LEN -1 )) ); do
            fieldname="${stub}_${i}_NAME"; dname="${!fieldname}"
            fieldname="${stub}_${i}_TEMPLATE"; dtemplate="${!fieldname}"
            fieldname="${stub}_${i}_LOCALE"; dlocale="${!fieldname}"
            fieldname="${stub}_${i}_EXTENSIONS"; dextensions="${!fieldname}"
            fieldname="${stub}_${i}_OWNER"; downer="${!fieldname}"
            
            # database exists, create or abort
            gosu postgres psql -lqt | cut -d \| -f 1 | grep -qw "$dname"
            if test $? -ne 0; then
                if test -e /app/etc/flags/force.prepare.postgres.createdb; then
                    gosu postgres createdb ${dname} \
                        -T ${dtemplate:-template0} \
                        -l ${dlocale:-de_DE.utf8}
                else
                    appliance_failed "Appliance Standby" "Appliance is in standby, no postgresql database named $dname"
                fi
            fi

            # owner of database
            current_owner=$(gosu postgres psql -qtc "\l" |
                grep "^[ \t]*${dname}" | sed -r "s/[^|]+\| +([^| ]+) +\|.*/\1/")
            if test "$current_owner" != "$downer"; then
                gosu postgres psql -c "ALTER DATABASE ${dname} OWNER TO ${downer};"
            fi
            
            # extensions of database
            for j in $dextensions; do 
                if ! $(gosu postgres psql ${dname} -qtc "\dx" | grep -q $j); then
                    # create extension
                    gosu postgres psql ${dname} -c "CREATE extension $j;"
                fi
            done
        done
        
        if test -e /app/etc/flags/force.prepare.postgres.createdb; then
            rm /app/etc/flags/force.prepare.postgres.createdb
        fi
    fi
}


check_postgresql_update(){
    local postgres_list postgres_old postgres_new
    local postgres_need_update=false
    local postgres_forced=false

    if test -e /app/etc/flags/force.update.postgres; then 
        postgres_need_update=true
        postgres_forced=true
    fi
    
    # XXX needs up to date package list for proper results
    postgres_list=$(apt-cache policy postgresql-{{ settings.version }} -q | grep -E "(Installed|Candidate)")
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


do_postgresql_update() {
    if $1 != "true"; then echo "# Warning: skipping $0, because of param $1"; return; fi
    simple_metric postgresql_last_update counter "timestamp-epoch-seconds since last update to postgres" $start_epoch_seconds
    if test -e /app/etc/flags/force.update.postgresql; then
        rm /app/etc/flags/force.update.postgresql
    fi
    
    # for each database
    if test "$APPLIANCE_DATABASE_POSTGRESQL_DATABASE_LEN" != ""; then
        stub="APPLIANCE_DATABASE_POSTGRESQL_DATABASE"
        
        for i in $(seq 0 $(( $APPLIANCE_DATABASE_POSTGRESQL_DATABASE_LEN -1 )) ); do
            fieldname="${stub}_${i}_NAME"; dname="${!fieldname}"
            echo "Warning: prepare postgres update, kill all postgres connections to database $dname except ourself"
            gosu postgresql psql $dname -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$dname' AND pid <> pg_backend_pid();"
        done
    fi
}

