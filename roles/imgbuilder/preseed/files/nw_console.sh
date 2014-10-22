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

tmux_opts="-s networkconsole '/sbin/debian-installer /bin/network-console-menu'"
TERM=linux ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" -o "StrictHostKeyChecking=no" \
    -t $ssh_opts $* root@$ssh_target "tmux new $tmux_opts || tmux attach"

