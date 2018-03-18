#!/bin/bash

# wait for server
while ! curl -k https://localhost/ping; do sleep 3; done

# try to login with password from environment
LOGINRESPONSE=`curl -s 'https://127.0.0.1/v3-public/localProviders/local?action=login' -H 'content-type: application/json' --data-binary '{"username":"admin","password":"{{ settings.password }}"}' --insecure`
LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`

if test "$LOGINTOKEN" = ""; then
    # try with default credentials, change credentials
    LOGINRESPONSE=`curl -s 'https://127.0.0.1/v3-public/localProviders/local?action=login' -H 'content-type: application/json' --data-binary '{"username":"admin","password":"admin"}' --insecure`
    LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`
    
    # Change password
    curl -s 'https://127.0.0.1/v3/users?action=changepassword' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"currentPassword":"admin","newPassword":"{{ settings.password }}"}' --insecure
fi

# Create API key
APIRESPONSE=`curl -s 'https://127.0.0.1/v3/token' -H 'content-type: application/json' -H "Authorization: Bearer $LOGINTOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure`
# Extract and store token
APITOKEN=`echo $APIRESPONSE | jq -r .token`

# Get-XXX or Create cluster
CLUSTERRESPONSE=`curl -s 'https://127.0.0.1/v3/cluster' -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --data-binary '{"type":"cluster","nodes":[],"rancherKubernetesEngineConfig":{"ignoreDockerVersion":true},"name":"{{ settings.clustername }}"}' --insecure`
# Extract clusterid
CLUSTERID=`echo $CLUSTERRESPONSE | jq -r .id`

# write server environment
cat > /app/etc/rancher-server.env << EOF
APITOKEN=${APITOKEN}
CLUSTERID=${CLUSTERID}
RANCHERSERVER="{{ settings.rancherserver }}"
EOF
