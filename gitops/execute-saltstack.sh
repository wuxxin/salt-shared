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


build_from_lp_usage() { # $1=source $2=dest
    cat <<EOF
Usage: $0 <pkgname> <target-dir> [--source distro] [--dest distro]
        [--debbuildopts <options>] [--ver-suffix <suffix>] [<patch-file>*]

pkgname         = source package name from launchpad
target-dir      = directory where the resulting packages should be stored as apt archive
--source distro = defines the launch-pad branch to use, will default to "$1"
--dest   distro = build for distribution codename eg. "bionic", default=running system ($2)
--debbuildopts  = DEB_BUILD_OPTIONS for builder, eg. "nocheck"
--ver-suffix suffix
                = text to appended to version nr, eg. "~prebuild.1"
patch-file      = zero or more patch files to be applied via quilt before building source

EOF
    exit 1
}


build_from_lp() { # <pkgname> <target-dir> [--source distro] [--dest distro] [--debbuildopts <options>] [--ver-suffix <suffix>] [<patch-file>*]
    local source dest versuffix pkgname targetdir cowbasedir i need_install
    local basedir changes current_version new_version debbuildopts dsc_name dsc_file
    # defaults
    source=groovy
    dest="$(lsb_release -c -s)"
    versuffix=""
    debbuildopts=""

    # parse args
    if test "$2" = "" -o "$1" = "--help" -o "$1" = "-h"; then build_from_lp_usage $source $dest; fi
    pkgname=$1
    targetdir=$2
    shift 2
    if test "$1" = "--source"; then source=$2; shift 2; fi
    if test "$1" = "--dest"; then dest=$2; shift 2; fi
    if test "$1" = "--debbuildopts"; then debbuildopts="$2"; shift 2; fi
    if test "$1" = "--ver-suffix"; then versuffix=$2; shift 2; fi
    cowbasedir="/var/cache/pbuilder/base-$dest.cow"

    for i in $@; do
        if test ! -e $i; then
            echo "Error: patch $i specified but not found"
            exit 1
        fi
    done

    # setup builder
    need_install=false
    for i in pull-lp-source cowbuilder backportpackage quilt debchange apt-ftparchive; do
        if ! which $i > /dev/null; then need_install=true; break; fi
    done
    if $need_install; then
        DEBIAN_FRONTEND=noninteractive sudo apt-get update --yes
        DEBIAN_FRONTEND=noninteractive sudo apt-get install --yes cowbuilder ubuntu-dev-tools
    fi
    if ! grep -q "disco" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash -c 'echo "19.04,Disco Dingo,disco,2018-10-18,2019-04-18,2020-01-18" >> /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "eoan" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash -c 'echo "19.10,Eoan Ermine,eoan,2019-04-18,2019-10-17,2020-07-17" >>  /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "focal" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash -c 'echo "20.04 LTS,Focal Fossa,focal,2019-10-17,2020-04-23,2025-04-23,2025-04-23,2030-04-23" >>  /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "groovy" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash -c 'echo "20.10,Groovy Gorilla,groovy,2020-04-23,2020-10-22,2021-07-22" >>  /usr/share/distro-info/ubuntu.csv'
    fi
    if test ! -e "$cowbasedir"; then
        sudo cowbuilder --create --distribution "$dest" --basepath "$cowbasedir"
    else
        sudo cowbuilder --update --basepath "$cowbasedir"
    fi

    # create build directories
    basedir="$(mktemp -d)"
    mkdir -p "$basedir/build"
    pushd "$basedir"

    # get source
    pull-lp-source "$pkgname" "$source"

    if test "$1" != ""; then
        # add patches
        cd $(find . -type d -name "${pkgname}*" -print -quit)
        changes=""
        for i in $@; do
            quilt import $i
            changes="$changes $(basename $i)"
        done
        quilt push

        # update changelog
        current_version=$(head -1 debian/changelog | sed -r "s/[^(]+\(([^)]+)\).+/\1/g");
        new_version=${current_version:0:-1}$(( ${current_version: -1} +1 ))${versuffix};
        debchange -v "$new_version" --distribution $dest "experimental: $changes"
        # generate new source archive
        dpkg-source -b .
        cd ..
        dsc_name="${pkgname}*${versuffix}.dsc"
    else
        # without patches, dont use version suffix in dsc_name, because nothing changed
        dsc_name=""
    fi

    # build generated source
    dsc_file=$(find . -type f -name "$dsc_name" -print -quit)
    DEB_BUILD_OPTIONS="$debbuildopts" BASEPATH="$cowbasedir" backportpackage \
        -d "$dest" --builder=cowbuilder --dont-sign --build --workdir=build \
        -S "$versuffix" $dsc_file

    # generate local apt archive files
    cd build/buildresult
    apt-ftparchive packages . > Packages
    gzip -c < Packages > Packages.gz
    apt-ftparchive -o "APT::FTPArchive::Release::Origin=local" release . > Release
    gzip -c < Release > Release.gz
    cd ../..

    # wipe build directory
    cd /run
    if test -e "$targetdir"; then rm -rf "$targetdir"; fi
    mkdir -p "$targetdir"
    mv -t "$targetdir" $basedir/build/buildresult/*
    rm -rf "$basedir"
    popd
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
        if [[ "$os_codename" =~ ^(xenial|bionic|stretch|buster)$ ]]; then
            echo "installing saltstack ($salt_major_version) for python 3 from ppa"
            salt_major_version="3000"
            prefixdir="py3"
            wget -O - "https://repo.saltstack.com/${prefixdir}/${os_distributor}/${os_release}/${os_architecture}/${salt_major_version}/SALTSTACK-GPG-KEY.pub" | apt-key add -
            echo "deb [arch=${os_architecture}] http://repo.saltstack.com/${prefixdir}/${os_distributor}/${os_release}/${os_architecture}/${salt_major_version} ${os_codename} main" > /etc/apt/sources.list.d/saltstack.list
            DEBIAN_FRONTEND=noninteractive apt-get update --yes

        elif test "$os_codename" = "focal"; then
            echo "Currently (2020/05/15) there is no saltstack package for focal, building from latest launchpad source"
            custom_archive=/usr/local/lib/saltstack-custom-archive
            custom_sources_list=/etc/apt/sources.list.d/local-saltstack-custom.list
            build_from_lp salt $custom_archive --debbuildopts nocheck --ver-suffix "~prebuild.1"
            cat > $custom_sources_list << EOF
deb [ trusted=yes ] file:$custom_archive ./
EOF
            DEBIAN_FRONTEND=noninteractive apt-get update --yes
        else
            echo "installing distro buildin saltstack version"
        fi
    else
        echo "installing distro buildin saltstack version"
    fi

    DEBIAN_FRONTEND=noninteractive apt-get install -y salt-minion curl gosu git gnupg git-crypt
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
