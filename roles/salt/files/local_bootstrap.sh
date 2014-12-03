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

# local call state.sls haveged and network
salt-call --local --config-dir={{ targetdir }} state.sls haveged,network
sleep 2

if test "{{ install.type }}" == "git"; then
# install salt-master from git
{{ targetdir }}/bootstrap-salt.sh -X -M git {{ install.rev }}
fi

# local call state.sls roles.salt.master (reconfigures salt.master)
salt-call --local --config-dir={{ targetdir }} state.sls roles.salt.master

# copy grains to final destination
cp {{ targetdir }}/grains /etc/salt/grains

# restart master
service salt-master stop; sleep 1; killall salt-master; service salt-master start; sleep 3

# stop minion, prepend logfiles from localrun over current minion logs, start minion
service salt-minion stop; sleep 1; killall salt-minion
if test -f /var/log/salt/minion.new; then rm /var/log/salt/minion.new; fi
mv /var/log/salt/minion /var/log/salt/minion.new
mv /srv/_run/log/minion /var/log/salt/minion
cat /var/log/salt/minion.new >> /var/log/salt/minion
rm /var/log/salt/minion.new
service salt-minion start; sleep 5

# accept minion key on master
salt-key -y -a {{ hostname }}.{{ domainname }}

# cleanup masterless leftovers, copy grains
#rm -r {{ targetdir }}/_run
rm {{ targetdir }}/minion {{ targetdir }}/grains

# sync grains, modules, states, etc.
salt-call saltutil.sync_all

# finally call highstate
#salt-call state.highstate
