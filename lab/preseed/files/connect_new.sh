#!/bin/bash
self_path=$(dirname $(readlink -e "$0"))
ssh_known_hosts="$self_path/known_hosts.newsystem"
. $self_path/options.include

ssh -o "UserKnownHostsFile=$ssh_known_hosts" $ssh_opts root@$ssh_target "$@"
