#!/bin/bash
set -eo pipefail
set -x

usage() {
    cat <<EOF
    
Usage: $0 <target-dir> [--source distro] [--dest distro] [--version-postfix <postfix>] [<patch-file>*]

target-dir      = directory where the resulting packages should be stored as apt archive
--source distro = defines the launch-pad branch to use, will default to "$source"
--dest   distro = build for distribution codename eg. "bionic", default=running system ($dest)
--version-postfix postfix
                = text to appended to version nr, defaults to "custom"
patch-file      = zero or more patch files to be applied via quilt before building source

EOF
    exit 1
}

# defaults
source=focal
dest="$(lsb_release -c -s)"
verpostfix="custom"

# parse args
if test "$1" = "" -o "$1" = "--help" -o "$1" = "-h"; then usage; fi
targetdir=$1; shift
if test "$1" = "--source"; then source=$2; shift 2; fi
if test "$1" = "--dest"; then dest=$2; shift 2; fi
if test "$1" = "--version-postfix"; then verpostfix=$2; shift 2; fi
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
    DEBIAN_FRONTEND=noninteractive apt-get update --yes
    DEBIAN_FRONTEND=noninteractive apt-get install --yes cowbuilder ubuntu-dev-tools
fi
if ! grep -q "disco" /usr/share/distro-info/ubuntu.csv; then
    echo "19.04,Disco Dingo,disco,2018-10-18,2019-04-18,2020-01-18" >> /usr/share/distro-info/ubuntu.csv
fi
if ! grep -q "eoan" /usr/share/distro-info/ubuntu.csv; then
    echo "19.10,Eoan Ermine,eoan,2019-04-18,2019-10-17,2020-07-17" >>  /usr/share/distro-info/ubuntu.csv
fi
if ! grep -q "focal" /usr/share/distro-info/ubuntu.csv; then
    echo "20.04 LTS,Focal Fossa,focal,2019-10-17,2020-04-23,2025-04-23,2025-04-23,2030-04-23" >>  /usr/share/distro-info/ubuntu.csv
fi
if test ! -e "$cowbasedir"; then
    cowbuilder --create --distribution "$dest" --basepath "$cowbasedir"
else
    cowbuilder --update --basepath "$cowbasedir"
fi

# create build directories
basedir="$(mktemp -d)"
mkdir -p "$basedir/build"
cd "$basedir"

# get source
pull-lp-source docker.io "$source"
cd $(find . -type d -name "docker.io*" -print -quit)

# add patches
changes=""
for i in $@; do
    quilt import $i
    changes="$changes $(basename $i)"
done
quilt push

# update changelog
current_version=$(head -1 debian/changelog | sed -r "s/[^(]+\(([^)]+)\).+/\1/g");
new_version=${current_version:0:-1}$(( ${current_version: -1} +1 ))${verpostfix};
debchange -v "$new_version" --distribution $dest "experimental: $changes"
# generate new source archive
dpkg-source -b .
cd ..

# build generated source
BASEPATH="$cowbasedir" backportpackage -B cowbuilder -d "$dest" --dont-sign -b -w build docker*${verpostfix}*.dsc

# generate local apt archive files
cd build/buildresult
apt-ftparchive packages . > Packages
gzip -c < Packages > Packages.gz
apt-ftparchive -o "APT::FTPArchive::Release::Origin=local" release . > Release
gzip -c < Release > Release.gz
cd ../..

# copy buildresult to targetdir
if test -e "$targetdir"; then rm -rf "$targetdir"; fi
mkdir -p "$targetdir"
mv -t "$targetdir" $basedir/build/buildresult/*
rm -rf "$basedir"
