#!/bin/bash

if test ! -f ./diskpassword.crypted; then 
    echo "generate secret, you will be asked twice for a gpg symetric encryption passphrase to encrypt the secret"
    pwgen -s 22 1 | gpg --symmetric > ./diskpassword.crypted
fi

if test "{{ netcfg.ip|d('') }}" = ""; then
  ssh_target={{ hostname }}.{{ domainname }}
else
  ssh_target={{ netcfg.ip }}
fi

ssh_opts=""
if test "{{ custom_ssh_identity|d('') }}" != ""; then
  ssh_opts="-i {{ custom_ssh_identity }}"
fi

echo "testing access to targetmachine"
ping $ssh_target -c 4

echo "writing new custom.env to ssh_target, "
echo "you will be asked for the gpg encryption passphrase and then for your ssh key phrase"

cat | ssh -o "UserKnownHostsFile=./known_hosts.networkconsole" $ssh_opts -e none root@$ssh_target 'cat > /tmp/custom.env' << EOF
username={{ username }}
hostname={{ hostname }}
domainname={{ domainname }}
disks={{ disks }}
apt_proxy_mirror={{ apt_proxy_mirror }}
ip={{ netcfg.ip|d('') }}
netmask={{ netcfg.netmask|d('') }}
gateway={{ netcfg.gateway|d('') }}
dns={{ netcfg.dns|d('') }}
diskpassword=$(cat ./diskpassword.crypted | gpg --decrypt)
EOF

echo "now execute ./nw-console.sh, to shell into target machine,"
echo "and execute '/sbin/debian-installer /bin/network-console-menu'"
