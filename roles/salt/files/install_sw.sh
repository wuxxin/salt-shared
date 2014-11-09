#!/bin/bash

if test "{{ netcfg.ip|d('') }}" = ""; then
  ssh_target={{ hostname }}.{{ domainname }}
else
  ssh_target={{ netcfg.ip }}
fi

ssh_opts=""
if test "{{ custom_ssh_identity|d('') }}" != ""; then
  if test "{{ custom_ssh_identity|d('') }}" != "None"; then
    ssh_opts="-i {{ custom_ssh_identity }}"
  fi
fi

for a in saltadmin@{{ hostname }}.tar.xz local_bootstrap.dat; do
    scp -o "UserKnownHostsFile=./known_hosts.newsystem" $ssh_opts ./$a root@$ssh_target:/root
done

ssh -o "UserKnownHostsFile=./known_hosts.newsystem" $ssh_opts -f -e none root@$ssh_target << EOF
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y install gpg
echo "$(cat ./saltadmin@{{ hostname }}.secret.asc.crypted | gpg --decrypt)" | gpg --batch --yes --import - 
cd /root
mv local_bootstrap.dat local_bootstrap.sh
chmod +x local_bootstrap.sh
./local_bootstrap.sh
EOF




