#!/bin/sh
# local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"
KEYFILE="$2"
FULLCHAINFILE="$4"
cp $KEYFILE /app/etc/server.key.pem
cp $FULLCHAINFILE /app/etc/server.cert.pem
printf "%s" "$(if test -e /app/etc/dhparam.pem; then cat /app/etc/dhparam.pem; fi)" | cat /app/etc/server.cert.pem - > /app/etc/server.cert.dhparam.pem
