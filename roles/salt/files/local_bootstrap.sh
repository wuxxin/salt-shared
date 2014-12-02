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

if test "{{ install.type }}" == "git"; then
  rev="{{ install.rev }}"
  if test ! -f {{ targetdir }}/bootstrap-salt.sh; then
    curl -L {{ install.bootstrap }} -o {{ targetdir }}/bootstrap-salt.sh
    chmod +x {{ targetdir }}/bootstrap-salt.sh
  fi
  {{ targetdir }}/bootstrap-salt.sh -X git {{ install.rev }}
  # install salt-minion but do not start daemon
else
  # install custom ppa (and requisites for it), install salt masterless
  export DEBIAN_FRONTEND=noninteractive
  apt-get -y update
  apt-get -y install python-software-properties software-properties-common mercurial git-core
  apt-add-repository -y ppa:saltstack/salt
  apt-get -y update
  apt-get -y install salt-common
  # only install salt-call
fi

# generates minion config in /targetdir for a masterless setup
cat > {{ targetdir }}/minion << EOF
id: {{ hostname }}.{{ domainname }}
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

# add some extra commands if they are defined
{% if bootstrap_extra %}
{% for l in bootstrap_extra %}
{{ l }}
{% endfor %}
{% endif %}

# install git-crypt, checkout and unlocks git paths with git-unlock
salt-call --local --config-dir={{ targetdir }} state.sls git-crypt
for a in `find {{ targetdir }} -name .git-crypt -type d`; do 
  cd $a/..
  git-crypt unlock
done

# set salt minion name
mkdir -p /etc/salt
echo "{{ hostname }}.{{ domainname }}" > /etc/salt/minion_id

# call state.sls haveged and network
salt-call --local --config-dir={{ targetdir }} state.sls haveged,network
sleep 2

if test "{{ install.type }}" == "git"; then
# install salt-minion and salt-master, but only do configuration (no install)
{{ targetdir }}/bootstrap-salt.sh -X -M git {{ install.rev }}
fi

# call state.sls roles.salt.master, copy grains afterwards to final destination
salt-call --local --config-dir={{ targetdir }} state.sls roles.salt.master
cp {{ targetdir }}/grains /etc/salt/grains

# cleanup masterless leftovers, copy grains
rm -r {{ targetdir }}/_run
rm {{ targetdir }}/minion {{ targetdir }}/grains

# restart minion, accept minion key on master
service salt-master stop; sleep 1; killall salt-master; service salt-master start; sleep 3
service salt-minion stop; sleep 1; killall salt-minion; service salt-minion start; sleep 5
salt-key -y -a {{ hostname }}.{{ domainname }}

# sync grains, modules, states, etc.
salt-call saltutil.sync_all

# finally call highstate
#salt-call state.highstate
