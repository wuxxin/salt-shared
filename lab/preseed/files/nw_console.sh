#!/bin/bash

self_path=$(dirname $(readlink -e "$0"))
ssh_known_hosts="$self_path/known_hosts.networkconsole"
. $self_path/options.include

tmux_opts="-s networkconsole '/sbin/debian-installer /bin/network-console-menu'"
TERM=linux ssh -o "UserKnownHostsFile=$ssh_known_hosts" \
    -t $ssh_opts $* root@$ssh_target "tmux attach || tmux new $tmux_opts"

