#!/bin/bash

x=`readlink -f $0`
d=`dirname $x`

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

echo "copy linux, initrd.gz and a bash kexec execute file to target"
for a in ./linux ./initrd.gz; do 
    scp -o "UserKnownHostsFile=./known_hosts.legacy_system" -o "StrictHostKeyChecking=no" $ssh_opts $a root@$ssh_target:/root
done

echo "generate a kexec execute script (/root/kexec_this.sh) to target"
cat | ssh -o "UserKnownHostsFile=./known_hosts.legacy_system" -o "StrictHostKeyChecking=no" $ssh_opts -e none root@$ssh_target 'cat > /root/kexec_this.sh; chmod +x /root/kexec_this.sh' << EOF
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install kexec-tools
sudo kexec -l linux --initrd=initrd.gz --append="{{ cmdline }}"
sudo sync
sudo kexec -e

EOF

