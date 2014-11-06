#!/bin/bash

sudo apt-get install mercurial git-core
sudo add-apt-repository ppa:saltstack/salt
sudo apt-get update
sudo apt-get install salt-common python-msgpack python-zmq
myprog=`readlink -f $0`
mydir=`dirname $myprog`
myesc=`echo "$mydir" | sed -re 's/\\//\\\\\\//g'`


cat | sed -re "s/\\+BASE\\+/$myesc/g" > $mydir/minion << EOF

root_dir: +BASE+/_run

pidfile: salt-minion.pid
pki_dir: pki
cachedir: cache
sock_dir: run

file_client: local

fileserver_backend:
  - roots
  - git

#gitfs_remotes:
#  - https://github.com/saltstack-formulas/docker-formula.git

pillar_roots:
  base:
{% for a in pillars %}
    - +BASE+/{{ a }}
{% endfor %}

file_roots:
  base:
{% for a in states %}
    - +BASE+/salt/a
{% endfor %}

win_repo: '+BASE+/salt/salt-shared/win/repo'
win_repo_mastercachefile: '+BASE+/salt/salt-shared/win/repo/winrepo.p'

EOF

echo -e "id: `hostname`" >> $mydir/minion

cat > $mydir/sc.sh << "EOF"
#!/bin/sh

myprog=`readlink -f $0`
mydir=`dirname $myprog`
sudo salt-call --local --config-dir=$mydir $@

EOF

#sudo salt-call --local --config-dir=$mydir state.highstate
