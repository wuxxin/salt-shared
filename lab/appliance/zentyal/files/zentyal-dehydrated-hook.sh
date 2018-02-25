#!/usr/bin/env bash

function deploy_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

}

function clean_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

}

function deploy_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"
    sudo /usr/local/sbin/unchanged-cert-as-root.sh $1 $2 $3 $4 $5
}

function unchanged_cert {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"
    sudo /usr/local/sbin/deploy-cert-as-root.sh $1 $2 $3 $4 $5 $6
}

HANDLER=$1; shift; $HANDLER $@
