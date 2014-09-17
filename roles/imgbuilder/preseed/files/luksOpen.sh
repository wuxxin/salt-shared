 ssh -o "UserKnownHostsFile=~/.ssh/known_hosts.initramfs" \
-i "~/id_rsa.initramfs" root@initramfshost.example.com \
"echo -ne \"secret\" >/lib/cryptsetup/passfifo" 
