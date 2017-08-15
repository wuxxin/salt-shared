#!/bin/bash
self_path=$(dirname $(readlink -e "$0"))
ssh_known_hosts="$self_path/known_hosts.initramfs"
. $self_path/options.include

if test "$1" = "--cryptsetup"; then
  shift
  pass_target="| cryptsetup luksOpen /dev/md/luks_${hostname} luks_${hostname}_luks; vgchange -a y ${hostname}"
else
  pass_target="> /lib/cryptsetup/passfifo"
fi

ssh -o "UserKnownHostsFile=$ssh_known_hosts" -e none $ssh_opts root@$ssh_target \
    "echo -ne \"$(cat $diskpassword_crypted | gpg --decrypt)\" $pass_target"

