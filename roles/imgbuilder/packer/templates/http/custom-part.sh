#!/bin/sh
# Manually create partition configuration
# Partman does not currently support multi-disk lvm
# Designed to be run after download-installer but before partman-base
# This allows us to modify partman-base.postinst after it's been dropped in by anna
# Partman appears to be entirely an external program, removing the call to partman from partman-base.postinst prevents it from running.
 
case "$1" in
  installer)  
    # we should have d-i downloaded by now.  
    # partman comes in a udeb from the network so we have to hook here  
    # and replace the partman-base.postinst file
    sed -i 's/partman/\/tmp\/custom-part.sh partman/' /var/lib/dpkg/info/partman-base.postinst
    logger custom-part.sh modified partman-base.postinst
  ;;
  partman)  
    # do filesystem stuff: detect our config, fdisk, lvms, mount /target
    logger custom-part.sh partition configuration starting 
    modprobe dm_mod

    DISK_COUNT=`ls -1 /dev/sd? | wc -l`

    # Fallback to normal partman setup if we don't detect our disks
    if [ $DISK_COUNT -eq 0 ]; then
      logger -t lvm.sh Cannot detect disks, running partman
      partman
      exit
    fi
   
    # Partition map - on first two drives
    #  1 - /boot      (256meg)
    #  2 - LVM-vg0    (Remainder of disk)
    # Create partitions - first partition is mdadm software RAID, remainder for LVM
    for disk in /dev/sd[ab]; do
      parted -s $disk -- mklabel msdos
      # Reserve a bit of space before the first partition
      # It makes GRUB happy, since it can throw some modules and stuff there.
      parted -s $disk -- mkpart primary 256k 256                     # /boot
      parted -s $disk -- mkpart primary 256 100%                     # System LVM
      parted -s $disk -- set 1 raid on
      parted -s $disk -- set 2 boot on
      parted -s $disk -- set 2 raid on
      parted -s $disk -- set 2 lvm on
    done

    if [ $DISK_COUNT -ge 2 ]; then
      # /boot is setup as a software RAID1 array between sda and sdb
      #
      # sda2,sdb2 are combined into an RAID1 array that itself
      # is an LVM volume (system) with / and swap on it. This effectively
      # gives us 20gb on big disks for the operating system.
      #
      # sd{a,b}3 is the remaining space. It's usually 2 independent
      # LVM volumes, but some setups may prefer to convert it to a RAID1
      # volume in case the functionality on the machine requires more
      # resiliency to disk failure.
      mdadm -C /dev/md0 -v -f -n 2 -l 1 -R --name=boot /dev/sda1 /dev/sdb1
      mdadm -C /dev/md1 -v -f -n 2 -l 1 -R --name=vg0 /dev/sda2 /dev/sdb2

      BOOT=/dev/md0
      SYSTEM=/dev/md1  
    elif [ $DISK_COUNT -eq 1 ]; then
      # Oh well, no RAID for us.
      BOOT=/dev/sda1
      SYSTEM=/dev/sda2
    fi


    mke2fs -q -L boot $BOOT
    pvcreate -ff -y $SYSTEM
    vgcreate vg0 $SYSTEM
    lvcreate -L 20G -n root vg0
    lvcreate -L 100G -n home vg0
    lvcreate -L 20G -n var vg0

    mkfs.ext4 -q -L root /dev/vg0/root
    mkfs.ext4 -q -L home /dev/vg0/home
    mkfs.ext4 -q -L var /dev/vg0/var
   
    # setup common swap  
    # BUG: It's not possible with busybox mkswap to set a swap label
    # we'll just deal with this after provisioning....
    #lvcreate -L 20G -n swap vg0
    #mkswap -L swap /dev/vg0/swap
    #swapon /dev/vg0/swap
   
    # Create directory structure 
    mkdir /target
    mount /dev/vg0/root /target
    mkdir /target/home
    mount /dev/vg0/home /target/home
    mkdir /target/var
    mount /dev/vg0/var /target/var
    mkdir /target/boot
    mount $BOOT /target/boot
   
    # Create fstab 
    mkdir /target/etc 
    echo \# /etc/fstab: static file system information. > /target/etc/fstab
    echo \# >> /target/etc/fstab  echo "# <file system>   <mount point>   <type>   <options>       <dump> <pass>" >> /target/etc/fstab
    echo LABEL=root     /       ext4 acl,user_xattr              1  1 >> /target/etc/fstab 
    echo LABEL=home     /home   ext4 nodev,nosuid,acl,user_xattr 1  1 >> /target/etc/fstab 
    echo LABEL=var      /var    ext4 defaults                    1  1 >> /target/etc/fstab 
    echo LABEL=boot     /boot   ext2 defaults,nodev,noexec       1  2 >> /target/etc/fstab 
    echo proc           /proc   proc defaults                    0  0 >> /target/etc/fstab
   
    ;;
  destroy)
    logger lvm.sh Destroying existing volumes
    umount /target/boot
    umount /target/var
    umount /target/home
    umount /target
    swapoff /dev/vg0/swap

    pvremove -ff -y /dev/md1

    mdadm --stop /dev/md0
    mdadm --remove /dev/md0
    mdadm --zero-superblock /dev/sda1
    mdadm --zero-superblock /dev/sdb1
    mdadm --stop /dev/md1
    mdadm --remove /dev/md1
    mdadm --zero-superblock /dev/sda2
    mdadm --zero-superblock /dev/sdb2
  
    # Just for testing - remove before production use
    for disk in sda sdb sdc sdd; do
      for partition in 1 2 3 4 5 6 7; do
        parted -s /dev/$disk -- rm $partition
      done
    done

    ;;
 *) 
   echo $0: This script is destructive and should only be run as part of the debian-installer process

   ;;
esac

