#!/bin/bash

myprog=`readlink -f $0`
mydir=`dirname $myprog`

rev="2014.7"
if test ! -f /srv/bootstrap-salt.sh; then
  curl -L 'https://raw.githubusercontent.com/saltstack/salt-bootstrap/v2014.10.30/bootstrap-salt.sh' -o /srv/bootstrap-salt.sh
  chmod +x /srv/bootstrap-salt.sh
fi
/srv/bootstrap-salt.sh -M -X -G git $rev
