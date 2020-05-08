#!/bin/bash
#set -eo pipefail
#set -x

self_path=$(dirname "$(readlink -e "$0")")

firstuser=gitops
gitserver_sshport=22
authorized_keys="~/.ssh/id_rsa.pub ~/.ssh/id_ed25519.pub"

gitserver=pgit.on.ep3.at
gitserver_sshport=10023
gituser=wuxxin
gitgpguser=felix@ep3.at
gitreponame=k3s.goof
basepath=~/work
hostname=k3s.goof.ep3.at


usage(){
    cat << EOF
Usage: $0 basepath reponame gitserver gituser creator-gpgid hostname
    [--firstuser username #default=$firstuser] [--git-port gitsshport #default=$gitserver_sshport]
    [--authorized-keys authorized_keys #default="$authorized_keys"]
    [--no-saltstack] [--no-remote|--only-remote]

+ local
    + create (partly encrypted) gitops git repository
    + create and add access keys (git & git-crypt deployment, administration access)
    + add templates for quick start
+ remote
    + create repository on git server
    + add access key to git server
    + push repository to git server

creating and configuring the remote git repository using API Calls
(currently tested on gogs), needs the env variable "Authorization" to be set
to the gituser API token, eg. Authorization="token hexdigits".

+ Example
```sh
Authorization="token deadbeefdeadbeefdeadbeefdeadbeefdeadbeef" \
    ~/work k3s.goof pgit.on.ep3.at wuxxin felix@ep3.at k3s.goof.ep3.at \
        --git-port 10023 --authorized_keys ~/work/id_rsa
```
EOF
}


# create and enter source directory, make git repository
mkdir -p $basepath/$gitreponame
cd $basepath/$gitreponame
git init
# create first config files
mkdir -p config log run
printf "# ignores\n/log\n/run\n" > .gitignore
printf "hostname=%s\nfirstuser=%s\ngitops_user=%s\ngitops_target=%s\ngitops_source=%s\ngitops_branch=%s\n" \
    "$hostname" "$firstuser" "$firstuser" "/home/$firstuser" \
    "ssh://git@$gitserver:$gitserver_sshport/$gituser/$gitreponame.git" \
    "master" \
    > config/node.env
# copy current user ssh public key as authorized_keys
cat ~/.ssh/id_rsa.pub ~/.ssh/id_ed25519.pub \
    > config/authorized_keys
git add .
git commit -v -m "initial config"


# add git-crypt config
git-crypt init
cat > .gitattributes <<EOF
*secret* filter=git-crypt diff=git-crypt
*secrets* filter=git-crypt diff=git-crypt
**/secret/** filter=git-crypt diff=git-crypt
**/secrets/** filter=git-crypt diff=git-crypt
*id_rsa* filter=git-crypt diff=git-crypt
*id_ecdsa* filter=git-crypt diff=git-crypt
*id_ed25519* filter=git-crypt diff=git-crypt
*.sec* filter=git-crypt diff=git-crypt
*.key* filter=git-crypt diff=git-crypt
*.pem* filter=git-crypt diff=git-crypt
*.p12 filter=git-crypt diff=git-crypt
credentials* filter=git-crypt diff=git-crypt
csrftokens* filter=git-crypt diff=git-crypt
random_seed filter=git-crypt diff=git-crypt
.gitattributes !filter !diff
EOF
# add first git-crypt user
git-crypt add-gpg-user $gitgpguser
# create machine gpg id files
gpgutils.py gen_keypair gitops@node "$gitreponame" config/gitops@node-secret-key.gpg config/gitops@node-public-key.gpg
# add machine gpg id files to git-crypt
fixme!
git add .
git commit -v -m "add git-crypt config"


# add known_hosts and machine ssh id
ssh-keyscan -H -p $gitserver_sshport $gitserver > config/gitops.known_hosts
ssh-keygen -q -t ed25519 -N "$gitreponame" -f config/gitops.id_ed25519
git add .
git commit -v -m "add gitops ssh known_hosts, ssh deployment key"


# add saltstack
mkdir -p salt/custom
pushd salt
git submodule add https://github.com/wuxxin/salt-shared.git
popd
cat > config/top.sls << EOF
base:
  '*':
    - custom
EOF
cp salt/salt-shared/gitops/config.template.sls config/config.sls
cp salt/salt-shared/gitops/pillar.template.sls config/custom.sls
cp salt/salt-shared/gitops/state.template.sls salt/custom/top.sls
touch salt/custom/custom.sls
cat > bootstrap.sh <<"EOF"
#!/usr/bin/env bash
set -eo pipefail
self_path=$(dirname "$(readlink -e "$0")")
if test "$1" != "--yes"; then
    echo "Usage: $0 --yes [salt-call parameter, default=state.highstate]"
    exit 1
fi
shift
args="$@"
if test "$args" = ""; then args="state.highstate"; fi
exec $self_path/salt/salt-shared/gitops/execute-saltstack.sh $self_path "$args"
EOF
chmod +x bootstrap.sh
git add .
git commit -v -m "add saltstack skeleton"



# remote configuration, currently using the gogs api
# create origin repo on server
http -j  https://${gitserver}/api/v1/admin/users/${gituser}/repos \
    name=$gitreponame \
    description="my repo" \
    private:=true

# add deployment key
http -j https://${gitserver}/api/v1/repos/${gituser}/${gitreponame}/keys \
    title="machine@${gitreponame}" \
    key="$(cat config/gitops.id_ed25519.pub)"

# add origin to upstream
git remote add origin ssh://git@${gitserver}:${gitserver_sshport}/${gituser}/${gitreponame}.git

# push changes to origin
git push -u origin master
