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

echo "starting tmux, inside tmux: /sbin/debian-installer /bin/network-console-menu"
ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" $ssh_opts root@$ssh_target "export TERM=linux; export TERM_TYPE=network; tmux a || tmux"
