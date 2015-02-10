#!/bin/bash

myprog=`readlink -f $0`
mydir=`dirname $myprog`

if test "$1" = ""; then
    rev="2014.7"
else
    rev="$1"
fi
if test ! -f /srv/bootstrap-salt.sh; then
  curl -L 'https://raw.githubusercontent.com/saltstack/salt-bootstrap/v2015.01.12/bootstrap-salt.sh' -o /srv/bootstrap-salt.sh
  chmod +x /srv/bootstrap-salt.sh
fi
/srv/bootstrap-salt.sh -M -X -G git $rev
