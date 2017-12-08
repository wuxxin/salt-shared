#!/bin/bash

usage() {
    cat << EOF
Usage: $0 [optional script parameter] domain targetfile [salt-call parameter]

optional script parameter:
    --template custom-template      # use a different template. Default= $template
    --extra additional-yaml-env     # use additional yaml parameter for env

EOF
    exit 1
}


realpath=$(dirname $(readlink -e "$0"))
template="salt://appliance/env-template.yml"
minion=""
fileroot=""
pillarroot=""
extra_env=""
appuser=$USER

if test "$1" = "--template"; then
    template=$(readlink -f "$2")
    if test ! -e $template; then echo "Error: custom template $template not found"; usage; fi
    echo "Information: using custom template: $template"
    shift 2
fi
if test "$1" = "--extra"; then
    extra_env=$(readlink -f "$2")
    if test ! -e $extra_env; then echo "Error: extra yaml env $extra_env not found"; usage; fi
    echo "Information: using extra yaml env: $extra_env"
    shift 2
fi
if test -z "$2"; then usage; fi

domain=$1
targetfile=$(readlink -f "$2")
shift 2
echo "Domain: $domain, template: $template, extra_env: $extra_env, targetfile: $targetfile"

if test -e $realpath/env-create.sls; then
    echo "Info: we are called from the repository and not from a installed appliance"
    minion="--config-dir $(readlink -f $realpath/not-existing)"
    fileroot="--file-root $(readlink -f $realpath/../../)"
    pillarroot="--pillar-root $(readlink -f $realpath/not-existing)"
fi

sudo -- salt-call --local $fileroot $pillarroot $minion state.sls appliance.scripts.env-create pillar="{ \
    \"domain\": \"$domain\", \
    \"template\": \"$template\", \
    \"extra_env\": \"$extra_env\", \
    \"targetfile\": \"$targetfile\", \
    \"appuser\": \"$appuser\" }" "$@"
