#!/bin/sh
# Manually create partition configuration
#
# Partition map (type gpt) - on first two drives
#  1 - bios_grub (1Mb)
#  2 - /boot     (256meg)
#  3 - reserved  (1GiG, can be adjusted by $RESERVED_END in Mib)
#  4 - LVM-${VG_NAME}  (Remainder of disk)
#       ${VG_NAME}/host_root ($HOST_ROOT_SIZE)
#       ${VG_NAME}/host_swap ($HOST_SWAP_SIZE)
# if two drives, 2nd and 4rd partition will be mdadm RAID1 (2nd(boot) with 0.9 Metadata))


# defaults
VG_NAME=`debconf-get partman-auto-lvm/new_vg_name`
if test "$VG_NAME" = ""; then
    VG_NAME=`debconf-get netcfg/get_hostname`
fi
HOST_ROOT_SIZE='8g'
HOST_SWAP_SIZE='2g'
RESERVED_END='1280Mib'
DISKPASSWORD=''

# read and update environment variables from custom.env
if test -f /tmp/custom.env; then
  . /tmp/custom.env
fi

# prepare system name with luks if DISKPASSWORD is set
SYSTEM_NAME=${VG_NAME}
if test -n "$DISKPASSWORD"; then
    SYSTEM_NAME=luks_${VG_NAME}
fi


case "$1" in
  partman)  
    # do filesystem stuff: detect our config, fdisk, lvms, mount /target
    logger -t custom_part.sh partition configuration starting 

    DISK_PREFIX='s'
    DISK_COUNT=`ls -1 /dev/${DISK_PREFIX}d? | wc -l`
    if [ $DISK_COUNT -eq 0 ]; then
      DISK_PREFIX='v'
      DISK_COUNT=`ls -1 /dev/${DISK_PREFIX}d? | wc -l`
    fi

    if [ $DISK_COUNT -eq 0 ]; then
      logger -t custom_part.sh Cannot detect disks, running partman
      partman
      exit
    fi

    # Create partitions -
    for disk in /dev/${DISK_PREFIX}d[ab]; do
      parted -s $disk -- mklabel gpt
      parted -s $disk -- mkpart bios_grub 1024Kib 2048Kib
      parted -s $disk -- set 1 bios_grub on
      parted -s $disk -- mkpart boot 2048Kib 256Mib
      parted -s $disk -- set 2 boot on
      parted -s $disk -- set 2 raid on
      parted -s $disk -- mkpart reserved 256Mib ${RESERVED_END}
      parted -s $disk -- mkpart ${SYSTEM_NAME} ${RESERVED_END} 100%
      parted -s $disk -- set 4 raid on
    done

    if [ $DISK_COUNT -ge 2 ]; then
      # setup mdadm raid1
      apt-install mdadm

      BOOT=/dev/md0
      RAW_SYSTEM_NAME=${SYSTEM_NAME}
      RAW_SYSTEM_DEV=/dev/md/${RAW_SYSTEM_NAME}
      ln -s /dev/md1 /dev/md/${RAW_SYSTEM_NAME}

      mdadm -C /dev/md0 -v -f -R -n 2 -l 1 --metadata=0.90 --assume-clean --name=boot /dev/${DISK_PREFIX}da2 /dev/${DISK_PREFIX}db2
      mdadm -C /dev/md1 -v -f -R -n 2 -l 1 --assume-clean --name=${SYSTEM_NAME} /dev/${DISK_PREFIX}da4 /dev/${DISK_PREFIX}db4
      sleep 5
    elif [ $DISK_COUNT -eq 1 ]; then
      BOOT=/dev/${DISK_PREFIX}da2
      RAW_SYSTEM_NAME=${DISK_PREFIX}da4
      RAW_SYSTEM_DEV=/dev/${RAW_SYSTEM_NAME}
    fi

    if test -n "$DISKPASSWORD"; then
        # setup disk encryption
        apt-install cryptsetup

        LUKS_NAME=${RAW_SYSTEM_NAME}_luks
        SYSTEM_DEV=/dev/mapper/${LUKS_NAME}
        echo "LuksFormat $RAW_SYSTEM_DEV"
        echo "$DISKPASSWORD" | cryptsetup -q luksFormat $RAW_SYSTEM_DEV
        sleep 2
        echo "LuksOpen $RAW_SYSTEM_DEV $LUKS_NAME"
        echo "$DISKPASSWORD" | cryptsetup luksOpen $RAW_SYSTEM_DEV $LUKS_NAME
        sleep 2
    else
        SYSTEM_DEV=$RAW_SYSTEM_DEV
    fi

    # setup boot partition
    mkfs.ext3 -q -L boot $BOOT

    # setup lvm
    apt-install lvm2
    pvcreate -ff -y $SYSTEM_DEV
    vgcreate ${VG_NAME} $SYSTEM_DEV
    lvcreate -L ${HOST_ROOT_SIZE} -n host_root ${VG_NAME}
    mkfs.ext4 -q -L host_root /dev/${VG_NAME}/host_root
   
    # setup common swap  
    lvcreate -L ${HOST_SWAP_SIZE} -n swap ${VG_NAME}
    mkswap -L swap /dev/${VG_NAME}/swap
    swapon /dev/${VG_NAME}/swap
   
    # Create directory structure 
    mkdir /target
    mount /dev/${VG_NAME}/host_root /target
    mkdir /target/boot
    mount $BOOT /target/boot
   
    # Create fstab 
    mkdir /target/etc 
    echo \# /etc/fstab: static file system information. > /target/etc/fstab
    echo \# >> /target/etc/fstab  echo "# <file system>   <mount point>   <type>   <options>       <dump> <pass>" >> /target/etc/fstab
    echo /dev/mapper/${VG_NAME}-host_root    /       ext4 acl,user_xattr              1  1 >> /target/etc/fstab
    echo LABEL=boot                          /boot   ext3 defaults,nodev,noexec       1  2 >> /target/etc/fstab
    echo LABEL=swap                          swap    swap  defaults                   0  0 >> /target/etc/fstab
    echo proc                                /proc   proc defaults                    0  0 >> /target/etc/fstab

    # create crypttab, schedule installation of cryptsetup and dropbear if we use encryption
    if test -n "$DISKPASSWORD"; then
        echo "$LUKS_NAME $RAW_SYSTEM_DEV none luks" > /target/etc/crypttab
    fi

    ;;
  destroy)
    logger -t custom_part.sh Destroying existing volumes
    umount /target/boot
    umount /target
    umount /media
    swapoff /dev/${VG_NAME}/swap

    DISK_PREFIX='s'
    DISK_COUNT=`ls -1 /dev/${DISK_PREFIX}d? | wc -l`
    if [ $DISK_COUNT -eq 0 ]; then
        DISK_PREFIX='v'
        DISK_COUNT=`ls -1 /dev/${DISK_PREFIX}d? | wc -l`
    fi

    vgremove -ff -y /dev/${VG_NAME}
    pvremove -ff -y /dev/mapper/md1_luks
    pvremove -ff -y /dev/${DISK_PREFIX}da4
    pvremove -ff -y /dev/md1
    pvremove -ff -y /dev/md126
    pvremove -ff -y /dev/md0
    pvremove -ff -y /dev/md127

    cryptsetup luksClose md1_luks
    cryptsetup luksClose ${DISK_PREFIX}da4_luks

    mdadm --stop /dev/md0
    mdadm --remove /dev/md0
    mdadm --stop /dev/md1
    mdadm --remove /dev/md1
    mdadm --stop /dev/md126
    mdadm --remove /dev/md126
    mdadm --stop /dev/md127
    mdadm --remove /dev/md127
    mdadm --zero-superblock /dev/${DISK_PREFIX}da2
    mdadm --zero-superblock /dev/${DISK_PREFIX}db2
    mdadm --zero-superblock /dev/${DISK_PREFIX}da4
    mdadm --zero-superblock /dev/${DISK_PREFIX}db4
    ;;
 *) 
   echo $0: This script is destructive and should only be run as part of the debian-installer process

   ;;
esac

