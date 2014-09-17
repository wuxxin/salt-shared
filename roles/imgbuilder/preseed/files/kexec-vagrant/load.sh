inactive_opts=""
opts="{{ cmdline }}"

#sudo apt-get update
sudo apt-get install kexec-tools
cd /home/vagrant; sudo kexec -l linux --initrd=initrd.gz --append="$opts"
sudo sync
sudo kexec -e


