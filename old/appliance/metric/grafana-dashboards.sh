#!/bin/bash

dashboard_exists () {
    printf "%s" "$2" | grep -q "\"$1\""
}

dashboard_id () {
    printf "%s" "$2" | grep "\"$1\"" | sed -r "s/..id.:([0-9]+).*/\1/"
}

usage () {
  cat << EOF

$0 export hostname exportdir
  + make a copy of all grafana dashboards from the grafana server to the export dir

$0 import importdir hostname
  + copies all grafana dashboard jsons from the import dir to the grafana server

+ this shell script is to be executed on the user machine
+ connects to remote grafana using ssh to hostname and forward port 3000 to local port 3333
+ you must set env var \$GRAFANA_KEY to a valid grafana api key.
  to get a new key, browse your grafana instance as user under /org/apikeys
+ you need jq, nc and curl installed. (apt install jq curl nc)

EOF
  exit 1
}

if test "$3" = ""; then usage; fi

cmd=$1
HOST="http://localhost:3333"

if test "$1" = "export"; then
    server=$2
    targetdir=$3
elif test "$1" = "import"; then
    server=$3
    targetdir=$2
elif test "$1" = "list"; then
    server=$2
else
    echo "error: either export or import is required"
    usage
fi

if test "$GRAFANA_KEY" = ""; then echo "error: env GRAFANA_KEY not found"; usage; fi
for i in nc jq curl; do
    if ! which $i > /dev/null; then echo "error: $i not found"; usage; fi
done

echo "ssh to server $server"
ssh -nNL 3333:localhost:3000 root@$server &
tunnel_pid=$!
printf "waiting for tunnel"
while ! nc -z localhost 3333; do
  printf "."
  sleep 0.25
done
printf "\n"

if test "$cmd" = "export"; then
    if test ! -d "$targetdir"; then
        mkdir -p "$targetdir"
    fi

    for dashboard in $(curl -sSLk "${HOST}/api/search?query=&" \
        -H "Authorization: Bearer ${GRAFANA_KEY}" | \
        jq '.' | grep -i uri | awk -F '"uri": "' '{ print $2 }' | \
        awk -F '"' '{print $1 }'); do

        dashboardfile=$(echo ${dashboard}|sed 's,db/,,g').json
        echo "Processing $dashboardfile"
        curl -sSLk "${HOST}/api/dashboards/${dashboard}" \
            -H "Authorization: Bearer ${GRAFANA_KEY}" | \
            jq '.dashboard.id = null | .overwrite = true | del(.meta) | del(.__inputs) | del(.__requires)' > "$targetdir/$dashboardfile"
    done

elif test "$cmd" = "import"; then
    current_list=$(curl -sSLk "${HOST}/api/search?query=&" \
        -H "Authorization: Bearer ${GRAFANA_KEY}" | \
        jq -r ".[]| {id,title} |tostring ")

    for dashboardfile in $targetdir/*.json; do
        title=$(cat $dashboardfile | jq -r ".dashboard.title")
        echo "Processing $dashboardfile ($title)"

        if dashboard_exists "$title" "$current_list"; then
            id=$(dashboard_id "$title" "$current_list")
            echo "Updating: $title with id $id "
            cat $dashboardfile | jq '.overwrite = true | .dashboard.id = '$id | \
                curl -sSLk -XPOST "${HOST}/api/dashboards/db" \
                -H "Authorization: Bearer ${GRAFANA_KEY}" \
                -H "Content-Type: application/json" \
                -H "Accept: application/json" \
                --data-binary @-
        else
            echo "New Dashboard: $title"
            cat $dashboardfile | jq '.overwrite = false' | \
                curl -sSLk -XPOST "${HOST}/api/dashboards/db" \
                -H "Authorization: Bearer ${GRAFANA_KEY}" \
                -H "Content-Type: application/json" \
                -H "Accept: application/json" \
                --data-binary @-
        fi
        printf "\n"
  	done
else
    current_list=$(curl -sSLk -H "Authorization: Bearer ${GRAFANA_KEY}" "${HOST}/api/search?query=&" | \
        jq -r ".[]| {id,title} |tostring ")
    echo "$current_list"
fi

kill $tunnel_pid
