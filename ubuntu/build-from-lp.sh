#!/usr/bin/bash
set -eo pipefail
set -x

self_path=$(dirname "$(readlink -e "$0")")

usage() {
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


build_from_lp() {
    # <pkgname> <target-dir> [--source distro] [--dest distro]
    # [--debbuildopts <options>] [--ver-suffix <suffix>] [<patch-file>*]
    local source dest versuffix pkgname targetdir cowbasedir i need_install
    local basedir changes current_version new_version debbuildopts dsc_name dsc_file
    # defaults
    source=hirsute
    dest="$(lsb_release -c -s)"
    versuffix=""
    debbuildopts=""

    # parse args
    if test "$2" = "" -o "$1" = "--help" -o "$1" = "-h"; then usage $source $dest; fi
    pkgname=$1
    targetdir=$(readlink -f $2)
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
    if ! grep -q "bionic" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash 'echo "18.04 LTS,Bionic Beaver,bionic,2017-10-19,2018-04-26,2023-04-26,2023-04-26,2028-04-26" >> /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "cosmic" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash 'echo "18.10,Cosmic Cuttlefish,cosmic,2018-04-26,2018-10-18,2019-07-18" >> /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "disco" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash 'echo "19.04,Disco Dingo,disco,2018-10-18,2019-04-18,2020-01-18" >> /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "eoan" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash 'echo "19.10,Eoan Ermine,eoan,2019-04-18,2019-10-17,2020-07-17" >>  /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "focal" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash 'echo "20.04 LTS,Focal Fossa,focal,2019-10-17,2020-04-23,2025-04-23,2025-04-23,2030-04-23" >>  /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "groovy" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash 'echo "20.10,Groovy Gorilla,groovy,2020-04-23,2020-10-22,2021-07-22" >>  /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "hirsute" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash 'echo "21.04,Hirsute Hippo,hirsute,2020-10-22,2021-04-22,2022-01-22" >>  /usr/share/distro-info/ubuntu.csv'
    fi
    if ! grep -q "impish" /usr/share/distro-info/ubuntu.csv; then
        sudo /usr/bin/bash 'echo "21.10,Impish Indri,impish,2021-04-22,2021-10-14,2022-07-14" >>  /usr/share/distro-info/ubuntu.csv'
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
        versuffix=""
    else
        # without patches, dont use version suffix in dsc_name, because nothing changed
        dsc_name="${pkgname}*.dsc"
    fi

    # build generated source
    dsc_file=$(find . -type f -name "$dsc_name" -print -quit)
    DEB_BUILD_OPTIONS="$debbuildopts" BASEPATH="$cowbasedir" backportpackage \
        -d "$dest" --builder=cowbuilder --dont-sign --build --workdir=build \
        $(if test "$versuffix" != ""; then echo "-S $versuffix"; fi) $dsc_file

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


build_from_lp "$@"
