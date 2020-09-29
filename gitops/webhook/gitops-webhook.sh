#!/bin/bash
#set -eo pipefail
#set -x

self_path=$(dirname "$(readlink -e "$0")")


usage(){
    cat << EOF

Usage:  $0 create <reponame> <gitserver> <gituser> <webhook_target> [--output <file>]

- needs env variable "Authorization" set to the gituser API token,
    eg. 'Authorization="token deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"'

- writes the generated webhook secret to stdout or --output filename

eg. $0  k3s.goof ssh://pgit.on.ep3.at:10023 wuxxin \
        https://goof.ep3.at/hooks/k3s.goof.update \
        > k3s.goof.update.secret.env
EOF
}



webhook_url=https://goof.ep3.at/hooks/${gitreponame}.update
webhook_secret=$(openssl rand -base64 16)

# adding webhook secret
printf "webhook_url=%s\nwebhook_secret=%s\n" "$webhook_url" "$webhook_secret" \
    > config/gitops.${gitreponame}.webhook-secret.env
git add .
git commit -v -m "add webhook config"


# add webhook
http -j https://${gitserver}/api/v1/repos/${gituser}/${gitreponame}/hooks \
    type=gogs \
    config:='{}' \
    url="$webhookurl" \
    secret="$webhook_secret"
