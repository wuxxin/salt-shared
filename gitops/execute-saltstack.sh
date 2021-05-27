#!/bin/bash
set -eo pipefail
# set -x

self_path=$(dirname "$(readlink -e "$0")")


usage(){
    cat << EOF
Usage:  $0 [--config config_list --states states_list] base_path [salt-call parameter]

--config defaults to "$config_list"
--states defaults to "$states_list"
paths are relative to base_path

script rewrites $config_path/minion on execution

script expects root, or call with sudo as sudo able user

EOF
    exit 1
}


minion_config() { # $1=basepath $2=configpath $3=config_list $4=states_list
    local base_path config_path config_list states_list
    base_path=$1
    config_path=$2
    config_list=$3
    states_list=$4
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

}

salt_install() { # no parameter
    os_release=$(lsb_release -r -s)
    os_codename=$(lsb_release -c -s)
    os_distributor=$(lsb_release  -i -s | tr '[:upper:]' '[:lower:]')
    os_architecture=$(dpkg --print-architecture)

    if test "$os_architecture" = "amd64"; then
        if [[ "$os_codename" =~ ^(bionic|focal|stretch|buster)$ ]]; then
            echo "installing saltstack ($salt_major_version) for python 3 from ppa"
            salt_major_version="3003"
            prefixdir="py3"
            curl -L -s "https://repo.saltstack.com/${prefixdir}/${os_distributor}/${os_release}/${os_architecture}/${salt_major_version}/SALTSTACK-GPG-KEY.pub" | apt-key add -
            echo "deb [arch=${os_architecture}] http://repo.saltstack.com/${prefixdir}/${os_distributor}/${os_release}/${os_architecture}/${salt_major_version} ${os_codename} main" > /etc/apt/sources.list.d/saltstack.list
            DEBIAN_FRONTEND=noninteractive apt-get update --yes
        else
            echo "installing distro buildin saltstack version"
        fi
    else
        echo "installing distro buildin saltstack version"
    fi

    DEBIAN_FRONTEND=noninteractive apt-get install -y salt-minion python3-pytoml curl gosu git gnupg git-crypt
    echo "keep minion from running automatically"
    for i in disable stop mask; do systemctl $i salt-minion; done
}


main() {
    config_path=/etc/salt
    config_list="config"
    states_list="salt/salt-shared salt/custom"
    if test "$1" = "--config"; then config_list="$2"; shift 2; fi
    if test "$1" = "--states"; then states_list="$2"; shift 2; fi
    if test ! -e "$1"; then usage; fi
    base_path="$(readlink -e $1)"
    shift
    if which cloud-init > /dev/null; then
        # be sure that cloud-init has finished
        cloud-init status --wait || echo "Warning: Cloud init exited with error"
    fi
    if ! which salt-call > /dev/null; then
        salt_install
    fi
    minion_config "$base_path" "$config_path" "$config_list" "$states_list"
    echo "salt-call --local --config-dir=$config_path $@"
    salt-call --local --config-dir=$config_path "$@"
}

main "$@"
