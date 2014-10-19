#!/bin/bash

if test "{{ netcfg.ip|d('') }}" = ""; then
  ssh_target={{ hostname }}.{{ domainname }}
else
  ssh_target={{ netcfg.ip }}
fi


ssh_opts=""
if test "{{ custom_ssh_identity|d('') }}" != ""; then
  ssh_opts="-i {{ custom_ssh_identity }}"
fi

echo "start tmux with tmux; inside tmux: /sbin/debian-installer /bin/network-console-menu"
TERM=linux ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" -o "StrictHostKeyChecking=no" -e none $ssh_opts $* root@$ssh_target "tmux new /sbin/debian-installer /bin/network-console-menu"
