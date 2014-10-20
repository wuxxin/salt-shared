Debian/Ubuntu Preseed and Initrd Generator
==========================================

TODO:
 * modify all references to custom_env into debconf-get calls
 * add haveged also in initramfs of target boot
 * grub: textonly, no quiet as boot parameter

Target:
-------

 to make an customized automated install with advanced features

 * currently Ubuntu 14.04 only, should be possible to adopt to other versions and debian derivates

 * use it via:
   * kexec on a running system using the customized initrd and kernel
   * packer using an iso image and http served preseed files
   * vagrant-libvirt including libvirt.kernel,initrd,cmdline arguments
   * pxe boot

Features:
---------
 * generates a customized initrd and kernel for kexec or kernel, initrd setup
   and additional files needed for iso + preseed http setup
 * haveged (entropy generator) on install time
 * network console interactive ssh install with tmux on install time (option)
 * you can choose from different flavors of disk partitioning (simple, plain, lvm, lvm_crypt, custom)
 * uses an apt-proxy for package download if apt_proxy_mirror is present
 * ssh authorized_keys option
   * to activate include a custom_file "/.ssh/authorized_keys" into the setup
   * this enables both root and main user access via ssh authorized_keys, but deletes/locks the mainuser password
     and sudo is configured to sudo from main user without password
 * a watcher that reset the machine after a certain amount of time (in case automated install goes wrong)
   * to activate include a custom_file "/reboot.seconds" into the setup (with seconds as value inside file)
 * include debian packages inside initrd and install on runtime
   * use ./generate_overlay.sh on a ubuntu 14.04 amd64 machine
 * a custom installer with the following feature set:
   * gpt - [raid] - crypt - lvm - root setup with one or two disks
     including dropbear initrd support and patched initrd scripts for cryptdisk remote unlocking

Example:
........

 * headless server setup with two disks:
  luks encryption, raid1 on top, lvm on top, 
  ssh daemon inside initrd with the possiblity to ssh into and unlock the crypto root partition and boot

 * use roles.imgbuilder.lib.sls to make a custom configuration
 * example see prepare.sls

Details:
--------

kexec enabled distros:
......................
 * Ubuntu   >= 9.04
 * openSUSE >= 11.0"
 * Debian   >= 5.0
 * CentOS,
   RHEL     >= 5.3

generate compiled watch and custom libraries:
.............................................
 * compile new watch: gcc -O2 watch.c -o watch
 * make new overlay with extracted debs (runs only on same suite and architecture): ./generate_overlay.sh


Usage:
------

Prepare and install machine:

 * prepare initrd and other files
   * salt-call roles.imgbuilder.prepare

 * either:
   * boot target system and make sure you have ssh access to it
   * transfer kernel initrd and kexec script to target
     * ./load_kexec.sh
   * use "exit" to stop or start kexec installation with
     * ./kexec_this.sh
 * or:
   * start vagrant machine
     * vagrant up
   * press CTRL-C twice fast
   * watch console output via virtman or similar, edit boot parameter after installation to boot from harddisk

 * generate diskpassword, encrypt it and send it via ssh into installer
   * ./set_diskpassword.sh

 * ssh into installer and resume installation
   * ./nw_console.sh

   * resume installer
     * /sbin/debian-installer /bin/network-console-menu

 * after the installer is finished, and the machine is rebooted, open the cryptodisks on new machine
   * you may remove old ssh known_hosts entry before this will work

   * ./luksOpen.sh

 * continue installation on target part 2:

   * ./next-install.sh
