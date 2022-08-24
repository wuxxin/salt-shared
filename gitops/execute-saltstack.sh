#!/bin/bash
set -eo pipefail
# set -x
self_path=$(dirname "$(readlink -e "$0")")


usage() {
    cat << EOF
Usage:  $0  [--from-ppa]
            [--etc-dir <minion-config-dir>]
            [--config <list-of-paths> --states <list-of-paths>]
            <base_path> [<salt-call param>]

--etc-dir defaults to "$config_path"
--config defaults to "$config_list"
--states defaults to "$states_list"

+ script expects root, or to be called with sudo as allowed user
+ --config and --states paths are relative to <base_path>
+ a relative --etc-dir path will be prepended with <base_path>
+ execution overwrites any changes in "$config_path/minion"
+ --from-ppa try to install latest saltstack available from saltstack project source

EOF
    exit 1
}


minion_config() { # $1=base_path $2=config_path $3=config_list $4=states_list
    # generating $config_path/minion config file
    local base_path config_path config_list states_list
    base_path=$1; config_path=$2; config_list=$3; states_list=$4
    mkdir -p "$config_path"
    cat << EOF > "$config_path/minion"
id: $(hostname)
log_level_logfile: info
file_client: local

fileserver_backend:
- roots

pillar_roots:
  base:
$(for i in $config_list; do printf "  - %s\n" "$base_path/$i"; done)

file_roots:
  base:
$(for i in $states_list; do printf "  - %s\n" "$base_path/$i"; done)

grains:
  project_basepath: $base_path

EOF
}


salt_install() { # $1=salt_from_ppa(true|false)
    local os_release os_codename os_distributor os_architecture
    local i salt_from_ppa salt_major_version salt_repo_aptline salt_repo_keyfile
    salt_from_ppa="$1"
    os_release=$(lsb_release -r -s)
    os_codename=$(lsb_release -c -s)
    os_distributor=$(lsb_release  -i -s | tr '[:upper:]' '[:lower:]')
    os_hardware=$(uname -m)
    if test "$os_hardware" = "x86_64"; then
        os_architecture="amd64"
    elif [[ "$os_hardware" =~ ^(i386|i486|i586|i686)$ ]] ; then
        os_architecture="i386"
    else
        os_architecture=$os_hardware
    fi
    if [[ $os_distributor =~ ^(debian|ubuntu)$ ]]; then
        if test "$salt_from_ppa" = "true" -a "$os_architecture" = "amd64"; then
            if [[ $os_codename =~ ^(bionic|focal|stretch|buster|bullseye)$ ]]; then
                salt_major_version="latest"
                salt_ppa_url="repo.saltproject.io/py3"
                salt_repo_aptline="deb [arch=${os_architecture}] http://${salt_ppa_url}/${os_distributor}/${os_release}/${os_architecture}/${salt_major_version} ${os_codename} main"
                salt_repo_keyfile="https://${salt_ppa_url}/${os_distributor}/${os_release}/${os_architecture}/${salt_major_version}/SALTSTACK-GPG-KEY.pub"
                echo "installing saltstack ($salt_major_version) from ppa"
                curl -L -s "$salt_repo_keyfile" | apt-key add -
                echo "$salt_repo_aptline" > /etc/apt/sources.list.d/saltstack.list
                DEBIAN_FRONTEND=noninteractive apt-get update --yes
            fi
        fi
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
            salt-minion python3-pytoml curl git gnupg git-crypt
        # keep minion from running automatically
        for i in disable stop mask; do systemctl $i salt-minion; done
    elif test "$os_distributor" = "manjaro"; then
        pamac install --no-confirm --no-upgrade salt curl git gnupg git-crypt
    elif test "$os_distributor" = "arch"; then
        pacman -Sy salt curl git gnupg git-crypt
    fi
}


main() {
    config_path="/etc/salt"
    config_list="config"
    states_list="salt/salt-shared salt/local"
    from_ppa="false"
    if test "$1" = "--from-ppa"; then from_ppa="true"; shift; fi
    if test "$1" = "--etc-dir"; then config_path="$2"; shift 2; fi
    if test "$1" = "--config"; then config_list="$2"; shift 2; fi
    if test "$1" = "--states"; then states_list="$2"; shift 2; fi
    if test ! -e "$1"; then usage; fi
    base_path="$(readlink -e $1)"
    shift
    if test "${config_path:0:1}" != "/"; then
        config_path="$base_path/$config_path"
    fi
    if which cloud-init > /dev/null; then
        printf "waiting for cloud-init finish..."
        cloud-init status --wait || printf "exited with error: $?"
        printf "\n"
    fi
    if ! which salt-call > /dev/null; then
        salt_install "$from_ppa"
    fi
    minion_config "$base_path" "$config_path" "$config_list" "$states_list"
    echo "salt-call --local --config-dir=$config_path $@"
    salt-call --local --config-dir=$config_path "$@"
}

main "$@"
