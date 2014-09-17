#!/bin/bash

echo "this needs to be run from a machine with ubuntu 14.04 amd64"

overlay="./overlay"
debs="./debs"

mkdir $overlay
mkdir $debs

deb_list="libgcc1 libstdc++6 libevent-2.0-5 libncursesw5 libtinfo5 libhavege1 haveged tmux"

cd $debs; apt-get -y  download $deb_list
for d in $deb_list; do
    dpkg-deb -X $debs/${d}*.deb $overlay
done

# cd $overlay/bin; rm zcat; ln -s busybox zcat; rm gunzip; ln -s busybox gunzip

cd $overlay
tar czf ../files/overlay.tar.gz .

cd ..
rm -r $overlay
rm -r $debs
