#!/bin/bash
set -e

# read server environment
. /etc/rancher/rancher-server.env

# wait for server
while ! curl -k https://$RANCHERSERVER/ping; do sleep 3; done

# Generate agent image
AGENTIMAGE=$(curl -s -H "Authorization: Bearer $APITOKEN" "https://$RANCHERSERVER/v3/settings/agent-image" --insecure | jq -r .value)

# Generate token (clusterRegistrationToken)
AGENTTOKEN=$(curl -s "https://$RANCHERSERVER/v3/clusterregistrationtoken" -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$CLUSTERID'"}' --insecure | jq -r .token)

# Retrieve CA certificate and generate checksum
CACHECKSUM=$(curl -s -H "Authorization: Bearer $APITOKEN" "https://$RANCHERSERVER/v3/settings/cacerts" --insecure | jq -r .value | sha256sum | awk '{ print $1 }')

# write agent environment
mkdir -p /etc/rancher
cat > /etc/rancher/rancher-agent.env << EOF
AGENTIMAGE=${AGENTIMAGE}
AGENTTOKEN=${AGENTTOKEN}
CACHECKSUM=${CACHECKSUM}
RANCHERSERVER="${RANCHERSERVER}"
EOF

