#!/bin/bash
set -eo pipefail
# set -x

self_path=$(dirname "$(readlink -e "$0")")


usage(){
    cat << EOF
Usage:  $0 [--config <list> --states <states> [--add-default-skel]] <base_path> [<salt-call parameter>]

--config defaults to "$config_list"
--states defaults to "$states_list"
--add-default-skel writes additional default salt layout to base_path

script expects root, or be called with sudo as sudo able user.
paths are relative to <base_path>, script rewrites $config_path/minion on execution.

EOF
    exit 1
}


minion_config() { # $1=base_path $2=confi_gpath $3=config_list $4=states_list
    # $5=add_default_skel:true,*false*,''
    local base_path config_path config_list states_list add_default_skel
    base_path=$1; config_path=$2; config_list=$3; states_list=$4; add_default_skel=$5
    echo "generating $config_path/minion config file"
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
    if test "$add_default_skel" = "true"; then
        if ! which git > /dev/null; then
            DEBIAN_FRONTEND=noninteractive apt-get install -y git
        fi
        echo "generating salt skeleton at $base_path"
        mkdir -p $base_path/salt/local
        cd $base_path/salt
        git clone https://github.com/wuxxin/salt-shared.git
        cd $base_path
        printf "base:\n  '*':\n    - main\n" > $base_path/salt/local/top.sls
        mkdir -p $base_path/config
        cp $base_path/salt/local/top.sls $base_path/config/top.sls
    fi
}


salt_install() { # no parameter
    local os_release os_codename os_distributor os_architecture
    local i salt_major_version salt_repo_aptline salt_repo_keyfile
    os_release=$(lsb_release -r -s)
    os_codename=$(lsb_release -c -s)
    os_distributor=$(lsb_release  -i -s | tr '[:upper:]' '[:lower:]')
    os_architecture=$(dpkg --print-architecture)

    if which apt-get > /dev/null; then
        salt_major_version="3004"
        salt_repo_aptline="deb [arch=${os_architecture}] http://repo.saltstack.com/py3/${os_distributor}/${os_release}/${os_architecture}/${salt_major_version} ${os_codename} main"
        salt_repo_keyfile="https://repo.saltstack.com/py3/${os_distributor}/${os_release}/${os_architecture}/${salt_major_version}/SALTSTACK-GPG-KEY.pub"
        if test "$os_architecture" = "amd64"; then
            if [[ $os_codename =~ ^(bionic|focal|stretch|buster)$ ]]; then
                echo "installing saltstack ($salt_major_version) from ppa"
                curl -L -s "$salt_repo_keyfile" | apt-key add -
                echo "$salt_repo_aptline" > /etc/apt/sources.list.d/saltstack.list
                DEBIAN_FRONTEND=noninteractive apt-get update --yes
            else
                echo "installing distro buildin saltstack version"
            fi
        else
            echo "installing distro buildin saltstack version"
        fi

        DEBIAN_FRONTEND=noninteractive apt-get install -y \
            salt-minion python3-pytoml curl git gnupg git-crypt
        echo "keep minion from running automatically"
        for i in disable stop mask; do systemctl $i salt-minion; done

    elif which pamac > /dev/null; then
        echo "installing distro buildin saltstack version"
        pamac install --no-confirm --no-upgrade salt curl git gnupg git-crypt
    fi
}


main() {
    config_path=/etc/salt
    config_list="config"
    states_list="salt/salt-shared salt/local"
    if test "$1" = "--config"; then config_list="$2"; shift 2; fi
    if test "$1" = "--states"; then states_list="$2"; shift 2; fi
    if test "$1" = "--add-default-skel"; then add_default_skel="true"; shift; fi
    if test ! -e "$1"; then usage; fi
    base_path="$(readlink -e $1)"
    shift
    if which cloud-init > /dev/null; then
        printf "waiting for cloud-init finish..."
        cloud-init status --wait || printf "exited with error: $?"
        printf "\n"
    fi
    if ! which salt-call > /dev/null; then
        salt_install
    fi
    minion_config "$base_path" "$config_path" "$config_list" "$states_list"
    echo "salt-call --local --config-dir=$config_path $@"
    salt-call --local --config-dir=$config_path "$@"
}

main "$@"
