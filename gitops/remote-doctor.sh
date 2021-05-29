#!/usr/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 start

connects to a remote server defined in $config_file via ssh,
does a one way sync of the underlying git repository (except .git) to
the remote server's location of the sourcecode using unison.

This does not touch the .git directory, only the working copy of the repository.
use with care, while the sync is active, changes on the remote side are overwritten.

It should be useful to tryout changes without pushing it.
This is only safe if used in the context of the gitops state, or a similar setup.

EOF
    exit 1
}

ssh_uri() { # sshlogin [ssh,scp,host,port,user,known [--user newuser]]
    local sshlogin user userprefix port host known
    sshlogin=$1; user=""; userprefix=""; port="22"; host="${sshlogin#ssh://}"
    if test "$host" != "${host#*@}"; then
        user="${host%@*}"; userprefix="${user}@"
    fi
    host="${host#*@}"
    if test "${host}" != "${host%:*}"; then
        port="${host##*:}"
    fi
    host="${host%:*}"
    known="$(echo "$host" | sed -r 's/^([0-9.]+)$/[\1]/g')"
    if test "$port" != "22"; then
        known="${known}:${port}"
    fi
    if test "$3" = "--user"; then
        user="$4"
    fi
    if test "$2" = "host"; then     echo "$host"
    elif test "$2" = "port"; then   echo "$port"
    elif test "$2" = "user"; then   echo "$user"
    elif test "$2" = "scp"; then    echo "scp://${userprefix}${host}:${port}/"
    elif test "$2" = "known"; then  echo "$known"
    else echo "ssh://${userprefix}${host}:${port}"
    fi
}

# try to find the base of the machine repository, expects a gitops setup
self_path=$(dirname "$(readlink -e "$0")")
base_path=$(readlink -m "$self_path/../../../")
base_name=$(basename "$base_path")
config_path="$(readlink -m "$base_path/config")"
config_file=$config_path/node.env

if ! which unison > /dev/null; then
    echo "error: missing dependencies, try: sudo apt-get install unison"
    usage
fi
if test ! -e "$config_file"; then
    echo "error: config $config_file not found"
    usage
fi
if test "$1" != "start"; then usage; fi

# read node.env, modify the sshlogin with the gitops_user, construct remote_src
. $config_file
remote_user=$gitops_user
remote_sshlogin=$(ssh_uri ${sshlogin} ssh --user $remote_user)
remote_src=$gitops_target/$base_name

# if test "$(ssh ${remote_sshlogin} "which unison")" = ""; then
#     echo "error: missing remote dependencies, try: ssh $(ssh_uri ${sshlogin}) apt-get install unison"
#     usage
# fi

echo "start unison, exit with CTRL-C"
one way only to remote, also ignore .git and probably if possible content of .gitignore
fixme unison \
    ${base_path} \
    ${remote_sshlogin}${remote_src} \
    -repeat watch -terse
