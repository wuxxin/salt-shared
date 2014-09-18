#!/bin/bash
ssh -o "UserKnownHostsFile=./known_hosts.initramfs" -i "vagrant.key" 192.168.121.27 "echo -ne \"$(cat disk.passwd)\" >/lib/cryptsetup/passfifo"
