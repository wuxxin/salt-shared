#!/bin/bash
self_path=$(dirname $(readlink -e "$0"))
ssh_known_hosts="$self_path/known_hosts.legacy_ystem"
. $self_path/options.include

echo "copy linux, initrd.gz and a bash kexec execute file to target"
for a in $self_path/linux $self_path/initrd.gz; do 
    scp -o "UserKnownHostsFile=$ssh_known_hosts" $ssh_opts $a root@$ssh_target:/root
done

echo "generate a kexec execute script (/root/kexec_this.sh) to target"
cat | ssh -o "UserKnownHostsFile=$ssh_known_hosts" $ssh_opts \
    -e none root@$ssh_target 'cat > /root/kexec_this.sh; chmod +x /root/kexec_this.sh' << EOF
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y update
sudo apt-get -y install kexec-tools
sudo kexec -l linux --initrd=initrd.gz --append="$kernel_cmdline"
sudo sync
sudo kexec -e

EOF

