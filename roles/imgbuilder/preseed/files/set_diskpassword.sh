#!/bin/bash

if test ! -f ./diskpassword.crypted; then 
    echo "importing {{ diskpassword_receiver_id }}.key.asc into local keychain"
    gpg --batch --yes --import ./{{ diskpassword_receiver_id }}.key.asc

    if test -f ./{{ diskpassword_receiver_id }}.secret.asc; then
        echo "importing {{ diskpassword_receiver_id }}.secret.asc into local keychain"
        gpg --batch --yes --import ./{{ diskpassword_receiver_id }}.secret.asc
    fi

    echo "generating secret using {{ diskpassword_creation }} and encrypting it with {{ diskpassword_receiver_key }}"
    {{ diskpassword_creation }} |
    gpg --batch --yes --always-trust --recipient {{ diskpassword_receiver_id }} --output ./diskpassword.crypted --encrypt
fi

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

if test ! -f ./known_hosts.networkconsole; then
    ssh_opts="$ssh_opts -o StrictHostKeyChecking=no"
fi

echo -n  "testing ip access to target: "
until ping $ssh_target -c 4 -q; do
  echo -n .
done

echo -n "testing ssh access to target: "
until ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" $ssh_opts root@$ssh_target exit; do
  echo -n .
  sleep 1
done

echo "writing new custom.env to ssh_target, "
echo "you may be asked 1.) for the gpg encryption passphrase and then 2.) for your ssh key phrase"

ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" -f -e none $ssh_opts root@$ssh_target \
"echo -e \"DISKPASSWORD=$(cat ./diskpassword.crypted | gpg --decrypt)\n\" > /tmp/custom.env"
x=$?
if test $x -ne 0; then
  echo "ERROR: ssh exited with error code $x"
else
  echo "now execute ./nw-console.sh, to shell into target machine, for resuming installation"
fi
