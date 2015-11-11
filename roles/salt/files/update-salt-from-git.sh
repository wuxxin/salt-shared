#!/bin/bash

myprog=`readlink -f $0`
mydir=`dirname $myprog`

if test "$1" = ""; then
    rev="latest"
else
    rev="$1"
fi
if test ! -f /srv/bootstrap-salt.sh; then
  curl -L 'https://bootstrap.saltstack.com' -o /srv/bootstrap-salt.sh
  chmod +x /srv/bootstrap-salt.sh
fi
/srv/bootstrap-salt.sh -M -X -G git $rev
