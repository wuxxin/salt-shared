#!/bin/bash

if test ! -f ./diskpassword.crypted; then 
    echo "generating secret, you will be asked twice for a gpg symetric encryption passphrase to encrypt the secret"
    pwgen -s 22 1 | gpg --symmetric > ./diskpassword.crypted
fi

if test "{{ netcfg.ip|d('') }}" = ""; then
  ssh_target={{ hostname }}.{{ domainname }}
else
  ssh_target={{ netcfg.ip }}
fi

ssh_opts=""
if test "{{ custom_ssh_identity|d('') }}" != ""; then
  ssh_opts="-i {{ custom_ssh_identity }}"
fi

echo -n  "testing access to target: "
until ping $ssh_target -c 4 -q; do
  echo -n .
done
echo "ok"

echo "writing new custom.env to ssh_target, "
echo "you will be asked 1.) for the gpg encryption passphrase and then 2.) for your ssh key phrase"

ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" -o "StrictHostKeyChecking=no" -f  -e none $ssh_opts root@$ssh_target "echo \"$(cat ./diskpassword.crypted | gpg --decrypt)\" > /tmp/custom.env"

echo "now execute ./nw-console.sh, to shell into target machine,"
echo "and execute '/sbin/debian-installer /bin/network-console-menu'"
