#!/bin/bash
set -eo pipefail
set -x

RANCHERSERVER="https://{{ settings.server.name }}:{{ settings.server.https_port }}"

echo "wait for server"
while ! curl -k $RANCHERSERVER/ping; do sleep 3; done

echo "try to login with password from environment"
LOGINRESPONSE=$(curl -s "$RANCHERSERVER/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"{{ settings.server.password }}"}' --insecure || true)
LOGINTOKEN=$(echo "$LOGINRESPONSE" | jq -r .token || true)

if test "$LOGINTOKEN" = ""; then
    echo "try with default credentials"
    LOGINRESPONSE=$(curl -s "$RANCHERSERVER/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"admin"}' --insecure)
    LOGINTOKEN=$(echo "$LOGINRESPONSE" | jq -r .token)
fi

echo "change credentials"
curl -s "$RANCHERSERVER/v3/users?action=changepassword" -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"currentPassword":"admin","newPassword":"{{ settings.server.password }}"}' --insecure

echo "Create API key"
APIRESPONSE=$(curl -s "$RANCHERSERVER/v3/token" -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure)
# Extract and store token
APITOKEN=$(echo "$APIRESPONSE" | jq -r .token)

echo "Set server-url"
curl -s "$RANCHERSERVER/v3/settings/server-url" -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" -X PUT --data-binary '{"name":"server-url","value":"'$RANCHERSERVER'"}' --insecure > /dev/null

echo "Create cluster"
CLUSTERRESPONSE=$(curl -s "$RANCHERSERVER/v3/cluster" -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"cluster","nodes":[],"rancherKubernetesEngineConfig":{"ignoreDockerVersion":true},"name":"{{ settings.server.cluster }}"}' --insecure)
# Extract clusterid
CLUSTERID=$(echo "$CLUSTERRESPONSE" | jq -r .id)

echo "write server environment"
mkdir -p /etc/rancher
cat > /etc/rancher/rancher-server.env << EOF
APITOKEN=${APITOKEN}
CLUSTERID=${CLUSTERID}
RANCHERSERVER=${RANCHERSERVER}
EOF

