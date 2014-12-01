Debian/Ubuntu Preseed and Initrd Generator
==========================================

 A post-snowden network only access server setup generation tool
 to remotely install a server with fulldisk encryption in a secure way.

 Secondary Target: a customized automated ubuntu/debian machine install with advanced features.

 currently Ubuntu 14.04 only, should be possible to adopt to other versions and debian derivates.

 * use it via:
   * kexec on a running system using the customized initrd and kernel
   * packer using an iso image and http served preseed files
   * vagrant-libvirt including libvirt.kernel,initrd,cmdline arguments
   * pxe boot

 * Warning:
   This scripts only try to protect the permanent storage, aka. the harddisks, 
   and tries to safeguard the key material from accidently written to temporary storage

   If a attacker can snapshot the memory of the machine somehow, eg. pysically by
   "shuting off the machine while cooling memory chips before replugging them in a memory reader"
   he/she can then derive the encryption keys from the memory snapshot.

   This is also true for almost all types of hypervisors that are running a virtual machine.
   Eg. Your instance in the cloud.

   Therefore the only way to asure you can safely process encryption data is when you do the virtualization yourself,
   and you are not emulated while doing so.

Features:
---------
 * generates a customized initrd and kernel usable for many types of unattended installation
   (including a ISO image version, and support for whole disk encryption)
 * haveged (entropy generator) early on install time
 * network console interactive ssh install with tmux on install time
 * you can choose from different flavors of disk partitioning including a custom partition installer:
   * standard flavors: simple, plain, lvm, lvm_crypt
   * custom flavor: gpt - [raid] - crypt - lvm - root setup with one or two disks
       including dropbear initrd support and patched initrd scripts for cryptdisk remote unlocking
 * generate and encrypt the diskkey with a gpg public key on the source host and transfer it via ssh to the target
 * a paper backup script for generating a pdf with qrcodes of the setup files used (excluding initrd and kernel)
 * uses an apt-proxy for package download if present
 * ssh authorized_keys option
   * to activate include a custom_file "/.ssh/authorized_keys" into the setup
   * this enables both root and main user access via ssh authorized_keys, 
     but deletes & locks the mainuser password
     and sudo is configured to sudo from main user without password
 * a optional watcher that reset the machine after a certain amount of time (in case automated install goes wrong)
   * to activate include a custom_file "/reboot.seconds" into the setup (with seconds as value inside file)

Example:
........

headless server setup with two disks:  luks encryption, raid1 on top, lvm on top,
  ssh daemon inside initrd with the possiblity to ssh into and unlock the crypto root partition and boot

 * use roles.imgbuilder.preseed.example.sls as a start for a custom configuration
 * execute "salt-call state.sls yourpreparestate.sls" to generate kernel,initrd and shell scripts setup
 * go to "prepare and install machine"

Usage:
------

Prerequisites:
..............

 * a ssh keypair where the secret key is to be served by an local ssh agent
   * to generate a new ssh key use "ssh-keygen -l 2560"

 * a gpg keypair where the secret key is to be served by an local gpg agent
   * to generate a new gpg key use "gpg --keygen --length 2560"
   * export gpg public key (text version) "gpg --whatever"


Prepare and install machine:
............................

 * make a new directory (salt state)
  * copy roles/imgbuilder/preseed/example.sls and Vagrantfile to it as a starting point
  * modify example.sls to fit your needs
  * copy public ssh key and public gpg key to directory

 * prepare initrd and other files
   * salt-call state.sls your-salt-state-directory-name.prepare

 * real install:
   * boot target system and make sure you have ssh access to it
   * transfer kernel initrd and kexec script to target, save hostkey.legacy, ssh into target
     * ./load_kexec.sh
     * inside the target machine:
       * use "exit" to stop installation
       * or start kexec installation with "./kexec_this.sh"

 * test:
   * start vagrant machine
     * vagrant up
   * press CTRL-C twice fast
   * continue with step "generate and crypt diskpassword"
   * after setup finishes and the machine reboots:
     * shutoff machine, 
     * remove kernel/initrd/cmdline boot parameter from libvirt entry
     * reboot

 * generate and crypt diskpassword, ssh into installer ssh and set a diskpassword, save hostkey.nwconsole
   * ./set_diskpassword.sh

 * ssh into installer and resume installation at will
   * ./nw_console.sh
     * optional: select "start shell"
       * add custom settings like VG_NAME, HOST_ROOT_SIZE, HOST_SWAP_SIZE using "nano /tmp/custom.env"
         * defaults for VG_NAME=`debconf-get partman-auto-lvm/new_vg_name` if set or `debconf-get netcfg/get_hostname`
         * defaults for HOST_ROOT_SIZE='4G'
         * defaults for HOST_SWAP_SIZE='2G'
       * exit
     * continue installation: select "continue installation"

 * after the installer is finished, and the machine is rebooted, open the cryptodisks on new machine, save hostkey.initramfs
   * you may remove old ssh known_hosts entry before this will work
   * ./luksOpen.sh

 * check installation, and save host key
   * ./connect_new.sh exit

 * create a config archive and a printable qr code pdf of this archive
   * ./make_paper_config.sh


Details:
--------

kexec enabled distros:
......................
 * Ubuntu   >= 9.04
 * openSUSE >= 11.0"
 * Debian   >= 5.0
 * CentOS,
   RHEL     >= 5.3

(re)generate overlay or compiled watch and:
...........................................
 * make new overlay with extracted debs (runs only on same suite and architecture): ./generate_overlay.sh
 * compile new watch: gcc -O2 watch.c -o watch

further possible extensions:
----------------------------

   * add haveged also in initramfs of target boot
   * pwgen in initrd and seed debconf with it, use gpg to crypt for receiver and 
      *) needs gpg in the in-target setup
      1.) transfer file via scp to a target host before reboot
      2.) wait before reboot until file is marked as transfered
   * add qemu/kvm into initrd, start qemu/kvm with nested virtualization start a virtual machine inside the virtual machine
    * measure: tsc times on bare metal, 1level virtualization, 2ndlevel virtualization, make sanity checks,
      * mark system as "tainted" , change ssh setup to accept only recovery.key and has a different host key.

