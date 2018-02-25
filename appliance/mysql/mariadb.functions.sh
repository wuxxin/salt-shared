#!/bin/bash

prepare_mariadb_database () {

    local stub i fieldname uname upassword uoldpass 

    gosu mariadb pg_isready --timeout=10
    if test $? -ne 0; then
        appliance_failed "Appliance Standby" "Appliance is in standby, mariadb is not ready after 10 seconds"
    fi

    # check if user exists
    if test "$APPLIANCE_DATABASE_MYSQL_USER_LEN" != ""; then
        stub="APPLIANCE_DATABASE_MYSQL_USER"
        for i in $(seq 0 $(( $APPLIANCE_DATABASE_MYSQL_USER_LEN -1 )) ); do
            fieldname="${stub}_${i}_NAME"; uname="${!fieldname}"
            fieldname="${stub}_${i}_PASSWORD"; upassword="${!fieldname}"
            if ! $(gosu mariadb psql -c "\dg;" | grep $uname -q); then
                gosu mariadb createuser $uname
            fi
            
            uoldpass=$(gosu mariadb psql -q -t -c "select rolpassword from pg_authid where rolname = 'test';" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            if test "${upassword}" != "${uoldpass}"; then
                gosu mariadb psql -c "ALTER ROLE $uname WITH ENCRYPTED PASSWORD '"${upassword}"';"
            fi
        done
    fi

    # for each database
    if test "$APPLIANCE_DATABASE_MYSQL_DATABASE_LEN" != ""; then
        stub="APPLIANCE_DATABASE_MYSQL_DATABASE"
        for i in $(seq 0 $(( $APPLIANCE_DATABASE_MYSQL_DATABASE_LEN -1 )) ); do
            fieldname="${stub}_${i}_NAME"; dname="${!fieldname}"
            fieldname="${stub}_${i}_TEMPLATE"; dtemplate="${!fieldname}"
            fieldname="${stub}_${i}_LOCALE"; dlocale="${!fieldname}"
            fieldname="${stub}_${i}_EXTENSIONS"; dextensions="${!fieldname}"
            fieldname="${stub}_${i}_OWNER"; downer="${!fieldname}"
            
            # database exists, create or abort
            gosu mariadb psql -lqt | cut -d \| -f 1 | grep -qw "$dname"
            if test $? -ne 0; then
                if test -e /app/etc/flags/force.prepare.mariadb.createdb; then
                    gosu mariadb createdb ${dname} \
                        -T ${dtemplate:-template0} \
                        -l ${dlocale:-de_DE.utf8}
                else
                    appliance_failed "Appliance Standby" "Appliance is in standby, no mariadb database named $dname"
                fi
            fi

            # owner of database
            current_owner=$(gosu mariadb psql -qtc "\l" |
                grep "^[ \t]*${dname}" | sed -r "s/[^|]+\| +([^| ]+) +\|.*/\1/")
            if test "$current_owner" != "$downer"; then
                gosu mariadb psql -c "ALTER DATABASE ${dname} OWNER TO downer;"
            fi
            
            # extensions of database
            for j in $dextensions; do 
                if ! $(gosu mariadb psql ${dname} -qtc "\dx" | grep -q $j); then
                    # create extension
                    gosu mariadb psql ${dname} -c "CREATE extension $j;"
                fi
            done
        done
        
        if test -e /app/etc/flags/force.prepare.mariadb.createdb; then
            rm /app/etc/flags/force.prepare.mariadb.createdb
        fi
    fi
}


check_mariadb_update(){
    local mariadb_list mariadb_old mariadb_new
    local mariadb_need_update=false
    local mariadb_forced=false

    if test -e /app/etc/flags/force.update.mariadb; then 
        mariadb_need_update=true
        mariadb_forced=true
    fi
    
    # XXX needs up to date package list for proper results
    mariadb_list=$(apt-cache policy mariadb-{{ settings.version }} -q | grep -E "(Installed|Candidate)")
    mariadb_old=$(printf "%s" "$mariadb_list" | grep "Installed" | sed -r "s/.*Installed: ([^ ]+).*/\1/")
    mariadb_new=$(printf "%s" "$mariadb_list" | grep "Candidate" | sed -r "s/.*Candidate: ([^ ]+).*/\1/")
    if test "$mariadb_old" != "$mariadb_new"; then
        mariadb_need_update=true
    fi
  
    echo "appliance:do_MYSQL_update=$($mariadb_need_update && echo true || echo false)"
    if $mariadb_need_update; then
        echo "# information mariadb update: forced: $mariadb_forced , current: $mariadb_old , new: $mariadb_new"
        echo "$restart_str"
    fi
}


do_mariadb_update() {
    if $1 != "true"; then echo "# Warning: skipping $0, because of param $1"; return; fi
    simple_metric mariadb_last_update counter "timestamp-epoch-seconds since last update to mariadb" $start_epoch_seconds
    if test -e /app/etc/flags/force.update.mariadb; then
        rm /app/etc/flags/force.update.mariadb
    fi
    
    # for each database
    if test "$APPLIANCE_DATABASE_MYSQL_DATABASE_LEN" != ""; then
        stub="APPLIANCE_DATABASE_MYSQL_DATABASE"
        
        for i in $(seq 0 $(( $APPLIANCE_DATABASE_MYSQL_DATABASE_LEN -1 )) ); do
            fieldname="${stub}_${i}_NAME"; dname="${!fieldname}"
            echo "Warning: prepare mariadb update, kill all mariadb connections to database $dname except ourself"
            gosu mariadbql psql $dname -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$dname' AND pid <> pg_backend_pid();"
        done
    fi
}

