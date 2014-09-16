#!/usr/bin/env bash
x=`readlink -f $0`
d=`dirname $x`
if test -f Vagrantfile; then
    vagrant ssh-config > config

    targetname=`cat config | grep '^Host' | sed -re "s/Host[ \t]+(.+)/\1/g"`

    for a in $d/*; do scp -F config $a vagrant@$targetname:/home/vagrant/ ; done

else
    echo "Usage: execute within a directory of a Vagrantfile"
fi

