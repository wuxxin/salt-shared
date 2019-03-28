#!/bin/bash

self_path=$(dirname $(readlink -e "$0"))
ssh_known_hosts="$self_path/known_hosts.networkconsole"
. $self_path/options.include

if test ! -f $diskpassword_crypted; then 
    echo "importing $diskpassword_receiver_keyfile into local keychain"
    gpg --batch --yes --import $diskpassword_receiver_keyfile

    if test -f $diskpassword_receiver_secretfile; then
        echo "importing $diskpassword_receiver_secretfile into local keychain"
        gpg --batch --yes --import $diskpassword_receiver_secretfile
    fi

    echo "generating secret using $diskpassword_creation and encrypting it for $diskpassword_receiver_id"
    $diskpassword_creation |
      gpg --batch --yes --always-trust --recipient $diskpassword_receiver_id --output $diskpassword_crypted --encrypt
fi

echo -n  "testing ip access to target: "
until ping $ssh_target -c 4 -q; do
  echo -n .
done

echo -n "testing ssh access to target: "
until ssh -o "UserKnownHostsFile=$ssh_known_hosts" $ssh_opts root@$ssh_target exit; do
  echo -n .
  sleep 1
done

echo "writing new custom.env to ssh_target, "
echo "you may be asked 1.) for the gpg encryption passphrase and then 2.) for your ssh key phrase"

ssh -o "UserKnownHostsFile=$ssh_known_hosts" -f -e none $ssh_opts root@$ssh_target \
  "echo -e \"DISKPASSWORD=$(cat $diskpassword_crypted | gpg --decrypt)\n\" > /tmp/custom.env"
x=$?
if test $x -ne 0; then
  echo "ERROR: ssh exited with error code $x"
else
  echo "now execute ./nw-console.sh, to shell into target machine, for resuming installation"
fi
