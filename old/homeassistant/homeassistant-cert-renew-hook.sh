#!/bin/bash
set -eo pipefail
# set -x

usage() {
    cat << EOF
Usage: $0 --from-cert-hook

Environment:
    DOMAIN
    KEYFILE
    CERTFILE
    FULLCHAINFILE
EOF
    exit 1
}

if test "$1" != "--from-cert-hook"; then usage; fi
if test "$CERTFILE" = ""; then
    echo "error: env variable CERTFILE must be set"
    usage
fi

current_watch=$(if test -e $CERTWATCHFILE; then cat $CERTWATCHFILE; fi)
new_watch=$(printf "%s\n$CERTFILE" "$current_watch" | sort | uniq)
printf "%s" "$new_watch" > $CERTWATCHFILE
