#!/bin/bash
set -eo pipefail
# set -x
self_path=$(dirname "$(readlink -e "$0")")

usage() {
    cat <<EOF
clone and update an optional encrypted git repository

Install Usage: $0 bootstrap
    --url <giturl> --branch <branch>
    --user <user> --home <homedir> --git-dir <clonedir>
    [--export-dir <targetdir>] [--gitrev-dir <gitrevdir>]
    [--keys-from-stdin | --keys-from-file <filename>]

Update Usage: $0 pull
    --url <giturl> --branch <branch>
    --user <user> --git-dir <clonedir>
    [--export-dir <targetdir>] [--gitrev-dir <gitrevdir>]

Mandatory Parameter:

--url <giturl>        # url of git repository
--branch <branch>     # branchname
--user <user>         # user to be created and owner of the targetdir files
--home <homedir>      # home directory of user to be created
--git-dir <clonedir>  # directory where the source should be cloned to

Optional Parameter:

--export-dir <targetdir>
    directory with the checked out specific source version

--gitrev-dir <gitrevdir>
    directory where to create GIT_REV, GIT_BRANCH, GIT_ID.py
    GIT_REV will be set to include GIT revision
    GIT_BRANCH will be set to includes GIT branch
    GIT_ID.py will be set to include: GIT_REV,GIT_BRANCH and GIT_VERSION python escaped

--keys-from-file <filename>
--keys-from-stdin
    reads an openssh privatekey, openssh known hosts data, and optional gpg key data
    needed to connect to a git repository via ssh and unlock git-crypt secrets
    with all data coming from stdin.

    + openssh private key, can be rsa or ed25519
    + known hosts data, must be pre- and post-fixed with
        + prefix:   "# ---BEGIN OPENSSH KNOWN HOSTS---"
        + postfix:  "# ---END OPENSSH KNOWN HOSTS---"
    + gpg key, needs to be ascii armored

EOF
    exit 1
}

gosu() {
    local user home
    user=$1
    shift
    if which gosu >/dev/null; then
        gosu $user $@
    else
        home="$(getent passwd "$user" | cut -d: -f6)"
        setpriv --reuid=$user --regid=$user --init-groups env HOME=$home $@
    fi
}

extract_gpg() {
    local head="-----BEGIN PGP PRIVATE KEY BLOCK-----"
    local bottom="-----END PGP PRIVATE KEY BLOCK-----"
    echo "$1" | grep -qPz "(?s)$head.*$bottom"
    if test $? -ne 0; then return 1; fi
    echo "$1" | awk "/$head/,/$bottom/"
}

extract_ssh() {
    local oldhead="-----BEGIN RSA PRIVATE KEY-----"
    local oldbottom="-----END RSA PRIVATE KEY-----"
    local newhead="-----BEGIN OPENSSH PRIVATE KEY-----"
    local newbottom="-----END OPENSSH PRIVATE KEY-----"
    echo "$1" | grep -qPz "(?s)$oldhead.*$oldbottom"
    if test $? -eq 0; then
        echo "$1" | awk "/$oldhead/,/$oldbottom/"
    else
        echo "$1" | grep -qPz "(?s)$newhead.*$newbottom"
        if test $? -ne 0; then return 1; fi
        echo "$1" | awk "/$newhead/,/$newbottom/"
    fi
}

extract_known_hosts() {
    local head='# ---BEGIN OPENSSH KNOWN HOSTS---'
    local bottom='# ---END OPENSSH KNOWN HOSTS---'
    echo "$1" | grep -qPz "(?s)$head.*$bottom"
    if test $? -ne 0; then return 1; fi
    echo "$1" | awk "/$head/,/$bottom/"
}

ssh_type() {
    echo "$@" | grep -q -- "-----BEGIN RSA PRIVATE KEY-----"
    if test $? -eq 0; then
        echo "id_rsa"
    else
        echo "$@" | grep -q -- "-----BEGIN OPENSSH PRIVATE KEY-----"
        if test $? -eq 0; then
            echo "id_ed25519"
        fi
    fi
}

pull_latest_src() {
    # $1=src_url $2=src_branch $3=target_dir $4=user
    local src_url src_branch target_dir user
    src_url="$1"
    src_branch="$2"
    target_dir="$3"
    user="$4"

    # clone, update source code as user
    if test ! -d "$target_dir"; then
        install -o "$user" -g "$user" -d "$target_dir"
        gosu "$user" git clone "$src_url" "$target_dir"
    else
        chown -R "$user:$user" "$target_dir"
        old_src_url=$(gosu "$user" git -C "$target_dir" config --get remote.origin.url || echo "invalid")
        if test "$src_url" != "$old_src_url"; then
            echo "Warning: new/different upstream source, will re-clone."
            echo "Current: \"$old_src_url\", new: \"$src_url\""
            rm -r "$target_dir"
            install -o "$user" -g "$user" -d "$target_dir"
            gosu "$user" git clone "$src_url" "$target_dir"
        fi
    fi
    gosu "$user" git -C "$target_dir" fetch -a -p
    gosu "$user" git -C "$target_dir" checkout -f "$src_branch"
    gosu "$user" git -C "$target_dir" reset --hard "origin/$src_branch"
    gosu "$user" git -C "$target_dir" submodule update --init --recursive
}

export_src() {
    # $1=src_dir $2=target_dir $3=user
    local src_dir target_dir user
    src_dir="$1"
    target_dir="$2"
    user="$3"

    # checkout specified source to target_dir
    install -o "$user" -g "$user" -d "$target_dir"
    gosu "$user" bash "git -C $src_dir archive --format=tar HEAD | tar -x -C $target_dir"
}

write_gitrev_files() {
    # $1=src_dir $2=output_dir $3=$user
    local src_dir output_dir user GIT_REV GIT_BRANCH GIT_VERSION
    src_dir="$1"
    output_dir="$2"
    user="$3"

    # get git_rev,branch,version, write out to output_dir/GIT_REV,GIT_BRANCH,GIT_ID.py
    install -o "$user" -g "$user" -d "$output_dir"
    GIT_REV="$(gosu "$user" git -C "$src_dir" rev-parse HEAD)"
    GIT_BRANCH="$(gosu "$user" git -C "$src_dir" rev-parse --abbrev-ref HEAD)"
    GIT_VERSION="$( (
        echo -n "${GIT_BRANCH} ${GIT_REV::10} "
        git -C "$src_dir" log --pretty=format:'%s' HEAD^..HEAD | cut -c -30
    ) | python3 -c 'print(repr(__import__("sys").stdin.read().strip()))')"
    echo "$GIT_REV" >"$output_dir/GIT_REV"
    echo "$GIT_BRANCH" >"$output_dir/GIT_BRANCH"
    cat >"$output_dir/GIT_ID.py" <<EOF
GIT_REV="$GIT_REV"
GIT_BRANCH="$GIT_BRANCH"
GIT_VERSION=$GIT_VERSION
EOF
}

# main
cd /run
src_url=""
src_branch=""
user=""
home_dir=""
clone_dir=""
target_dir=""
gitrev_dir=""
keys_from_file=""
sshkey=""
known_hosts=""
gpgkey=""

if test "$1" != "pull" -a "$1" != "bootstrap"; then usage; fi
cmd="$1"
shift

while true; do
    case $1 in
    --url)
        src_url=$2
        shift
        ;;
    --branch)
        src_branch=$2
        shift
        ;;
    --user)
        user=$2
        shift
        ;;
    --home)
        home_dir=$2
        shift
        ;;
    --git-dir)
        clone_dir=$2
        shift
        ;;
    --export-dir)
        target_dir=$2
        shift
        ;;
    --gitrev-dir)
        gitrev_dir=$2
        shift
        ;;
    --keys-from-file)
        keys_from_file="$2"
        shift
        ;;
    --keys-from-stdin) keys_from_file="-" ;;
    --)
        shift
        break
        ;;
    *) break ;;
    esac
    shift
done

if test "$src_url" = "" -o "$src_branch" = "" -o "$user" = "" -o "$clone_dir" = ""; then
    usage
fi
if test "$cmd" = "bootstrap" -a "$home_dir" = ""; then
    usage
fi
echo "url: $src_url branch: $src_branch"
echo "user: $user home: $home_dir git-dir: $clone_dir"
echo "export-dir: $target_dir gitrev-dir: $gitrev_dir"

# extract keys from input
if test "$keys_from_file" != ""; then
    keydata=$(cat $keys_from_file)

    sshkey=$(extract_ssh "$keydata") && result=true || result=false
    if ! $result; then
        if test "${src_url:0:3}" != "ssh"; then
            echo "Warning: no ssh key found from input"
        else
            echo "Error: src_url is using ssh, but no ssh key found from input"
            exit 1
        fi
    fi

    known_hosts=$(extract_known_hosts "$keydata") && result=true || result=false
    if ! $result; then
        if test "${src_url:0:3}" != "ssh"; then
            echo "Warning: no ssh known_hosts found from input"
        else
            echo "Error: src_url is using ssh, but no ssh known hosts found from input"
            exit 1
        fi
    fi

    gpgkey=$(extract_gpg "$keydata") && result=true || result=false
    if ! $result; then
        echo "Warning: no gpg key found from input"
    fi
    keydata=""
fi

if test "$cmd" = "bootstrap"; then
    # wait for cloud-init to finish, breaks pkg installing
    if which cloud-init >/dev/null; then
        printf "waiting for cloud-init finish..."
        cloud-init status --wait || printf "exited with error: $?"
        printf "\n"
    fi

    # force temporary locale
    export LANG="C.UTF-8"
    export LANGUAGE="C"
    export LC_MESSAGES="$LANG"

    if test ! -e /etc/default/locale; then
        # write forced locale as new default locale, if no default exists
        printf "LANG=%s\nLANGUAGE=%s\nLC_MESSAGES=%s\n" "$LANG" "$LANGUAGE" "$LC_MESSAGES" >/etc/default/locale
    fi

    # install base packages
    req_missing=false
    for i in "locale-gen curl git gpg git-crypt gosu"; do
        if ! which "$i" >/dev/null; then req_missing=true; fi
    done
    if test "$req_missing" = "true"; then
        os_distributor=$(lsb_release -i -s | tr '[:upper:]' '[:lower:]')
        if [[ $os_distributor =~ ^(debian|ubuntu)$ ]]; then
            DEBIAN_FRONTEND=noninteractive apt-get -y update
            DEBIAN_FRONTEND=noninteractive apt-get -y install \
                software-properties-common locales curl git gnupg git-crypt gosu
        elif test "$os_distributor" = "manjaro"; then
            # manjaro is missing gosu, will be replaced by setpriv in bash function gosu
            pamac install --no-confirm --no-upgrade glibc-locales curl git gnupg git-crypt
        fi
    fi

    # generate locale files if locale != C[.UTF-8]
    if test "$LANG" != "C" -a "$LANG" != "C.UTF-8"; then
        locale-gen $LANG
    fi

    # set temporary timezone if none set
    if test ! -e /etc/timezone; then
        echo "Etc/UTC" >/etc/timezone
        timedatectl set-timezone "Etc/UTC"
    fi

    # create user
    export HOME=$home_dir
    adduser --disabled-password --gecos ",,," --home "$home_dir" "$user" || true
    # write files from skeleton to homedir, overwrite if existing
    cp -r /etc/skel/. "$home_dir/."
    # recursive change all files in home_dir to user:user
    chown -R "$user:$user" "$home_dir"

    # install keys
    if test "$keys_from_file" != ""; then
        install -o "$user" -g "$user" -m "0700" -d "$home_dir/.ssh"

        if test "$sshkey" != ""; then
            sshkeytarget="$home_dir/.ssh/$(ssh_type \"$sshkey\")"
            echo "$sshkey" >"$sshkeytarget"
            chown "$user:$user" "$sshkeytarget"
            chmod "0600" "$sshkeytarget"
        fi
        if test "$known_hosts" != ""; then
            echo "$known_hosts" >"$home_dir/.ssh/known_hosts"
            chown "$user:$user" "$home_dir/.ssh/known_hosts"
            chmod "0600" "$home_dir/.ssh/known_hosts"
        fi
        if test "$gpgkey" != ""; then
            install -o "$user" -g "$user" -m "0700" -d "$home_dir/.gnupg"
            echo "$gpgkey" | gosu $user gpg --batch --yes --import || true
            gpg_fullname="$(basename $clone_dir) <gitops@node>"
            gpg_fingerprint=$(gosu $user gpg --batch --yes \
                --list-key --with-colons "$gpg_fullname" |
                grep "^fpr" | head -1 | sed -r "s/^.+:([^:]+):$/\1/g")
            # trust key absolute
            echo "$gpg_fingerprint:5:" | gosu $user gpg --batch --yes --import-ownertrust
        fi
    fi
fi

# download latest source
pull_latest_src "$src_url" "$src_branch" "$clone_dir" "$user"

if test "$gpgkey" != ""; then
    # unlock source if gpgkey is available
    pushd "$clone_dir" >/dev/null
    gosu $user git-crypt unlock
    popd >/dev/null
fi
if test "$target_dir" != ""; then
    # export specified source to target
    export_src "$clone_dir" "$target_dir" "$user"
fi
if test "$gitrev_dir" != ""; then
    # write out to gitrevdir/GIT_REV,GIT_BRANCH,GIT_ID.py
    write_gitrev_files "$clone_dir" "$gitrev_dir" "$user"
fi
