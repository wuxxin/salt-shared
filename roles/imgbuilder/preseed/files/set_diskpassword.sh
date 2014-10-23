#!/bin/bash

if test ! -f ./diskpassword.crypted; then 
    echo "importing {{ diskpassword_receiver_key }}.key.asc into local keychain"
    gpg --batch --yes --import ./{{ diskpassword_receiver_id }}.key.asc

    if test -f ./{{ diskpassword_receiver_id }}.secret.asc; then
        echo "importing {{ diskpassword_receiver_key }}.secret.asc into local keychain"
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

echo -n  "testing access to target: "
until ping $ssh_target -c 4 -q; do
  echo -n .
done
echo "ok"

echo "writing new custom.env to ssh_target, "
echo "you may be asked 1.) for the gpg encryption passphrase and then 2.) for your ssh key phrase"

ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" -o "StrictHostKeyChecking=no" \
-f  -e none $ssh_opts root@$ssh_target \
"echo -e \"diskpassword=$(cat ./diskpassword.crypted | gpg --decrypt)\n\" > /tmp/custom.env"

echo "now execute ./nw-console.sh, to shell into target machine, for resuming installation"
