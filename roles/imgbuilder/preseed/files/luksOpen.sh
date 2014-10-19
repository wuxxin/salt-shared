#!/bin/bash

if test "{{ netcfg.ip|d('') }}" = ""; then
  ssh_target={{ hostname }}.{{domainname }}
else
  ssh_target={{ netcfg.ip }}
fi

ssh_opts=""
if test "{{ custom_ssh_identity|d('') }}" != ""; then
  ssh_opts="-i {{ custom_ssh_identity }}"
fi

ssh -o "UserKnownHostsFile=./known_hosts.initramfs" $ssh_opts root@$ssh_target "echo -ne \"$(cat ./diskpassword.crypted | gpg --decrypt)\" >/lib/cryptsetup/passfifo"

