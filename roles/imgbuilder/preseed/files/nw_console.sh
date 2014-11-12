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
if test ! -f ./known_hosts.networkconsole; then
    ssh_opts="$ssh_opts -o \"StrictHostKeyChecking=no\""
fi

tmux_opts="-s networkconsole '/sbin/debian-installer /bin/network-console-menu'"
TERM=linux ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" \
    -t $ssh_opts $* root@$ssh_target "tmux new $tmux_opts || tmux attach"

