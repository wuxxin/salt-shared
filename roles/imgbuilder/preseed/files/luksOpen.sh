#!/bin/bash

if test "{{ netcfg.ip|d('') }}" = ""; then
  ssh_target={{ hostname }}.{{domainname }}
else
  ssh_target={{ netcfg.ip }}
fi

ssh_opts=""
if test "{{ custom_ssh_identity|d('') }}" != ""; then
  if test "{{ custom_ssh_identity|d('') }}" != "None"; then
    ssh_opts="-i {{ custom_ssh_identity }}"
  fi
fi

if test ! -f ./known_hosts.initramfs; then
    $ssh_opts="$ssh_opts -o \"StrictHostKeyChecking=no\""
fi

ssh -o "UserKnownHostsFile=./known_hosts.initramfs" -e none $ssh_opts root@$ssh_target "echo -ne \"$(cat ./diskpassword.crypted | gpg --decrypt)\" >/lib/cryptsetup/passfifo"

