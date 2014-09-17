Debian/Ubuntu Preseed and Initrd Generator
==========================================

TODO:
 * preseed diskpassword empty problem
 * add haveged also in initramfs of target boot
 * haveged hook (sleep)
 * more recordfail and other grub blockage (waits on mainscreen, and on a recordfail something screen), grub hook
 * change overlay generation to initramfs-tools copy-exec 


Target:
-------

 * currently Ubuntu 14.04 only, should be possible to adopt to other versions and debian derivates

Usage:
------

 to make an customized automated install (currently ubuntu)

 * via packer using an iso image and http served preseed files
 * via kexec on a running system using the customized initrd and kernel
 * via vagrant-libvirt including libvirt.kernel,initrd,cmdline arguments
 * via pxe

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
 * a watcher that reset the machine after a certain amount of time (in case automated install goes wrong)
   * to activate include a custom_file "/reboot.seconds" into the setup (with seconds as value inside file)
 * include debian packages inside initrd and install on runtime
   * use ./generate_overlay.sh on a ubuntu 14.04 amd64 machine
 * a custom installer with the following feature set:
   * gpt - [raid] - crypt - lvm - root setup with one or two disks
     including dropbear initrd support and patched initrd scripts for cryptdisk remote unlocking
   * include a /custom/custom.env for customize options (see custom_part.sh for possibilities)

Example:
--------

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

Prepare:
........
 * compile new watch: gcc -O2 watch.c -o watch
 * make new overlay with extracted debs (runs only on same suite and architecture): ./generate_overlay.sh
