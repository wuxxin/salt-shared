#!/bin/bash
set -eo pipefail
set -x

# read server environment
. /etc/rancher/rancher-server.env

echo "wait for server"
while ! curl -k $RANCHERSERVER/ping; do sleep 3; done

echo "Generate agent image"
AGENTIMAGE=$(curl -s "$RANCHERSERVER/v3/settings/agent-image" -H "Authorization: Bearer $APITOKEN" --insecure | jq -r .value)

echo "Generate token (clusterRegistrationToken)"
AGENTTOKEN=$(curl -s "$RANCHERSERVER/v3/clusterregistrationtoken" -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$CLUSTERID'"}' --insecure | jq -r .token)

echo "Retrieve CA certificate and generate checksum"
CACHECKSUM=$(curl -s "$RANCHERSERVER/v3/settings/cacerts" -H "Authorization: Bearer $APITOKEN" --insecure | jq -r .value | sha256sum | awk '{ print $1 }')

echo "write agent environment"
mkdir -p /etc/rancher
cat > /etc/rancher/rancher-agent.env << EOF
AGENTIMAGE=${AGENTIMAGE}
AGENTTOKEN=${AGENTTOKEN}
CACHECKSUM=${CACHECKSUM}
RANCHERSERVER="${RANCHERSERVER}"
EOF

