#!/bin/bash

myprog=`readlink -f $0`
mydir=`dirname $myprog`

# test for /targetdir/bootstrap.run and refuse to continue if already exists
if test -f {{ targetdir }}/bootstrap.run; then
    echo "ERROR: {{ targetdir }}/bootstrap.run already exists, aborting"
    exit 1
fi
mkdir -p -m 0755 {{ targetdir }}
touch {{ targetdir }}/bootstrap.run

# extract salt config to /targetdir
cd {{ targetdir }}
tar xaf /root/saltmaster@{{ hostname }}_config.tar.xz

# install custom ppa (and requisites for it), install salt masterless
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install python-software-properties software-properties-common mercurial git-core
apt-add-repository -y ppa:saltstack/salt
apt-get -y update
apt-get -y install salt-common python-msgpack python-zmq

# generates minion config in /targetdir for a masterless setup
cat > {{ targetdir }}/minion << EOF
id: {{ hostname }}
root_dir: {{ targetdir }}/_run
pidfile: salt-minion.pid
pki_dir: pki
cachedir: cache
sock_dir: run
file_client: local

fileserver_backend:
  - roots
  - git

pillar_roots:
  base:
{% for a in pillars %}
    - {{ targetdir }}/{{ a }}
{% endfor %}

file_roots:
  base:
{% for a in states %}
    - {{ targetdir }}/salt/{{ a }}
{% endfor %}

EOF

# install git-crypt, checkout and unlocks git paths with git-unlock
salt-call --local --config-dir={{ targetdir }} state.sls git-crypt
for a in `find {{ targetdir }} -name .git-crypt -type d`; do 
  cd $a/..
  git-crypt unlock
done

# install state.sls salt.master, copy grains, set salt minion name
salt-call --local --config-dir={{ targetdir }} state.sls roles.salt.master
cp {{ targetdir }}/grains /etc/salt/grains
echo "{{ hostname }}" > /etc/salt/minion_id

# cleanup masterless leftovers, copy grains
rm -r {{ targetdir }}/_run
rm {{ targetdir }}/minion {{ targetdir }}/grains

# restart minion, accept minion key on master
/etc/init.d/salt-minion restart
sleep 5
salt-key -y -a {{ hostname }}

# bootstrap network and storage, and finally call highstate
salt-call state.sls network
/etc/init.d/salt-master restart
/etc/init.d/salt-minion restart

salt-call state.highstate
