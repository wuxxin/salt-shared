
gosu postgres pg_isready --timeout=10
if test $? -ne 0; then
    appliance_failed "Appliance Standby" "Appliance is in standby, postgresql is not ready after 10 seconds"
fi

# check if user exists
if test "$APPLIANCE_DATABASE_POSTGRES_USER_LEN" != ""; then
    stub="APPLIANCE_DATABASE_POSTGRES_USER"
    for i in $(seq 0 $(( $APPLIANCE_DATABASE_POSTGRES_USER_LEN -1 )) ); do
        fieldname="$stub_${i}_NAME"; uname="${!fieldname}"
        fieldname="$stub_${i}_PASSWORD"; upassword="${!fieldname}"
        if ! $(gosu postgres psql -c "\dg;" | grep $uname -q); then
            gosu postgres createuser $uname
        fi
        gosu postgres psql -c "ALTER ROLE $uname WITH ENCRYPTED PASSWORD '"${upassword}"';"
    done
fi

# check if database exists
if test "$APPLIANCE_DATABASE_POSTGRES_DATABASE_LEN" != ""; then
    stub="APPLIANCE_DATABASE_POSTGRES_DATABASE"
    for i in $(seq 0 $(( $APPLIANCE_DATABASE_POSTGRES_DATABASE_LEN -1 )) ); do
        fieldname="$stub_${i}_NAME"; dname="${!fieldname}"
        fieldname="$stub_${i}_TEMPLATE"; dtemplate="${!fieldname}"
        fieldname="$stub_${i}_LC_CTYPE"; dlcctype="${!fieldname}"
        fieldname="$stub_${i}_LC_COLLATE"; dlccollate="${!fieldname}"
        fieldname="$stub_${i}_EXTENSIONS"; dextensions="${!fieldname}"
        fieldname="$stub_${i}_OWNER"; downer="${!fieldname}"
        
        gosu postgres psql -lqt | cut -d \| -f 1 | grep -qw "$dname"
        if test $? -ne 0; then
            appliance_failed "Appliance Standby" "Appliance is in standby, no postgresql database named $dname"
        fi

        current_owner=$(gosu postgres psql -qtc "\l" |
            grep "^[ \t]*${dname}" | sed -r "s/[^|]+\| +([^| ]+) +\|.*/\1/")
        if test "$current_owner" != "$downer"; then
            gosu postgres psql -c "ALTER DATABASE ${dname} OWNER TO downer;"
        fi
    done
fi



if ! $(gosu postgres psql ${ECS_DATABASE} -qtc "\dx" | grep -q pg_stat_statements); then
    # create pg_stat_statements extension
    gosu postgres psql ${ECS_DATABASE} -c "CREATE extension pg_stat_statements;"
fi


