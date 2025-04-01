#!/usr/bin/bash
set -eo pipefail
# set -x

usage(){
    cat << EOF
Usage: $0 sync|hard_reset --yes

$0 sync

    connects to a remote server defined in $config_file via ssh,
    does a continous **one way** sync of the working copy of the git repository
    (ignoring .git) to the remote server's location of the sourcecode using **unison**.

    This does **not** touch the .git directory on the remote side,
    only the working copy of the remote repository is modified.

    Before the sync is started, the state of the remote repository is checked,
    and the sync is aborted if the remote repository is unclean.

    while the sync is active, changes on the remote side working copy are overwritten.
    unison is needed on both sides. local side availability will be checked beforehand.

$0 hard_reset --yes

    mark a remote repository as clean by overwriting **ANY** changes in working tree,
    which calls "$hard_reset_git" on the target.

    after finished doctoring, assure to take care of the modified remote working copy,
    by. executing "$0 hard_reset --yes" to reset all changes.

EOF
    exit 1
}

hard_reset_git='git reset --hard --recurse-submodules HEAD'
is_clean_git='
    is_clean="true"
    if ! git diff-files --quiet --; then
        echo "error: working directory is not clean."
        git --no-pager diff-files --name-status -r --
        is_clean="false"
    fi
    if ! git diff-index --cached --quiet HEAD --; then
        echo "error: there are cached/staged changes"
        git --no-pager diff-index --cached --name-status -r HEAD --
        is_clean="false"
    fi
    if test "$(git ls-files --other --exclude-standard --directory)" != ""; then
        echo "error: working directory has extra files"
        git --no-pager ls-files --other --exclude-standard --directory
        is_clean="false"
    fi
    if test "$(git log --branches --not --remotes --pretty=format:"%H")" != ""; then
        echo "error: there are unpushed changes"
        git --no-pager log --branches --not --remotes --pretty=oneline
        is_clean="false"
    fi
    if test "$is_clean" = "true"; then
        echo "OK, is clean"
        exit 0
    fi
    exit 1
'

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

is_clean=$(ssh $sshopts "$(ssh_uri ${sshlogin})" "cd $remote_src; $is_clean_git")
if test "$is_clean" != "OK, is clean"; then
    echo "Error: remote repository is not clean."
    echo "$is_clean"
    exit 1
fi

echo 'starting sync, exit with CTRL-C, revert all remote changes with `$0 hard_reset --yes`'
unison default \
    ${base_path} \
    ${remote_sshlogin}${remote_src} \
    -noupdate ${base_path} \
    -force ${base_path} \
    -ignore .git \
    -repeat watch \
    -terse \
    -batch
