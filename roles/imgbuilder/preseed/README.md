Debian/Ubuntu Preseed and Initrd Generator
==========================================

TODO:
 * preseed diskpassword empty problem
 * additional dpkgs should be installed into initrd (needed for haveged and tmux)

usage: to make an customized automated install (currently ubuntu)
 * via packer using an iso image and http served preseed files
 * via kexec on a running system using the customized initrd and kernel
 * via vagrant-libvirt including libvirt.kernel,initrd,cmdline arguments
 * via pxe

Features:
 * generates a customized initrd and kernel for kexec or kernel,initrd setup
   and additional files needed for iso + preseed http setup

 * haveged (entropy generator) on install time

 * network console interactive ssh install with tmux on install time (option)

 * you can choose from different flavors of disk partitioning (simple, plain, lvm, lvm_crypt, custom)

 * uses apt-proxy at pillar('cache.apt') if present

 * ssh authorized_keys option
   * to activate include a custom_file "/.ssh/authorized_keys" into the setup

 * a watcher that reset the machine after a certain amount of time (in case automated install goes wrong)
   * to activate include a custom_file "/reboot.seconds" into the setup (with seconds as value inside file)

 * include debian packages inside initrd and install on runtime
   * use additional_dpkg

 * a custom installer with the following feature set:
   * raid - crypt - lvm setup with more than one disk
     including dropbear initrd support and patched initrd scripts for cryptdisk remote unlocking
   * include a /custom/custom_part.env for customize options (seed custom_part.sh for possibilities)

Example:
 * headless server setup with two disks:
  luks encryption, raid1 on top, lvm on top, 
  ssh daemon inside initrd with the possiblity to ssh into and unlock the crypto root partition and boot

kexec enabled distros:
 * Ubuntu   >= 9.04
 * openSUSE >= 11.0"
 * Debian   >= 5.0
 * CentOS,
   RHEL     >= 5.3

lib.sls: kexec_make Usage:
  see prepare.sls

Prepare:

 * make new watch
gcc -O2 watch.c -o watch

 * make new patch:
gzip < cryptroot.patch | busybox uuencode -m x

# make new deb list (runs only on same suite and architecture)
salt-call state.sls roles.imgbuilder.preseed.regenerate_overlay target=/srv/salt/custom/roles/imgbuilder/preseed/overlay

