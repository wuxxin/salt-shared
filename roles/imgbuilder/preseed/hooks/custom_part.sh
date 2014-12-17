#!/bin/sh
# Create partition configuration
#
# Partition map (type gpt)
#  1 - bios_grub  (1Mb)
#  2 - /boot      (256Mb)
#  3 - boot2      (256Mb)
#  4 - reserved   (1024Mb)
#  5 - ${VG_NAME} (LVM, remaining space of disk)
#      ${VG_NAME}/host_root ($HOST_ROOT_SIZE)
#      ${VG_NAME}/host_swap ($HOST_SWAP_SIZE)
#
# all size parameters are in megabyte, minimum disk size is 2+ 256*2+ 1024+ 8192+ 2048 = 11,5 GB ~ 12Gb
#
# if two or more drives, 2nd, 3rd partition will be mdadm RAID1
# if two drives: 5th partition will be RAID1, if more than two drives 5th partition will be RAID10
# if you have more drives than you want to use, you can limit the drives to use with MAX_DISKS=2 or 1 as you like
# if you want to encrypt the disks set DISKPASSWORD. Only Part 5 (RAID, LVM) will be crypted
# VG_NAME defaults to patman-auto-lvm/new_vg_name or netcfg/get_hostname if first is empty

# defaults
VG_NAME=`debconf-get partman-auto-lvm/new_vg_name`
if test "$VG_NAME" = ""; then
    VG_NAME=`debconf-get netcfg/get_hostname`
fi

BOOT_SIZE='256'
BOOT2_SIZE='256'
RESERVED_SIZE='1024'
HOST_ROOT_SIZE='8192'
HOST_SWAP_SIZE='2048'
MAX_DISKS=6

DISKPASSWORD=''

# read and update environment variables from custom_part.env
if test -f /tmp/custom_part.env; then
  . /tmp/custom_part.env
fi

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

    # limit used disks, generate name of device
    if test $DISK_COUNT -gt $MAX_DISKS; then
        DISK_COUNT=$MAX_DISKS
    fi
    DISK_NAMES='abcdef'
    # next line substitutes for bashism ${DISKNAMES:0:$DISK_COUNT}
    DISK_NAMES=$(expr "x$DISK_NAMES" : "x.\{,0\}\(.\{,$DISK_COUNT\}\)")
    DISK_PART="/dev/${DISK_PREFIX}d"

    # Create partitions
    for dshort in `echo ${DISK_NAMES} | sed 's/.\{1\}/& /g'`; do
      disk=${DISK_PART}${dshort}
      parted -s $disk -- mklabel gpt

      parted -s $disk -- mkpart bios_grub 1Mib 2Mib
      parted -s $disk -- set 1 bios_grub on

      posend=$((3+ BOOT_SIZE))
      parted -a optimal -s $disk -- mkpart boot 3Mib ${posend}Mib
      parted -s $disk -- set 2 boot on
      parted -s $disk -- set 2 raid on

      posbegin=$posend
      posend=$((posbegin+ BOOT2_SIZE))
      parted -a optimal -s $disk -- mkpart boot2 ${posbegin}Mib ${posend}Mib
      parted -s $disk -- set 3 raid on

      posbegin=$posend
      posend=$((posbegin+ RESERVED_SIZE))
      parted -a optimal -s $disk -- mkpart reserved ${posbegin}Mib ${posend}Mib

      posbegin=$posend
      parted -a optimal -s $disk -- mkpart ${SYSTEM_NAME} ${postbegin}Mib 100%
      parted -s $disk -- set 5 raid on
    done

    if [ $DISK_COUNT -ge 2 ]; then
      # setup mdadm raid1
      apt-install mdadm

      BOOT=/dev/md/boot
      BOOT2=/dev/md/boot2
      RAW_SYSTEM_NAME=${SYSTEM_NAME}
      RAW_SYSTEM_DEV=/dev/md/${RAW_SYSTEM_NAME}
      ln -s /dev/md0 $BOOT
      ln -s /dev/md1 $BOOT2
      ln -s /dev/md2 /dev/md/${RAW_SYSTEM_NAME}

      if test $DISK_COUNT -ge 3; then datalevel=10; else datalevel=1; fi
      mdadm -C /dev/md0 -v -f -R -n ${DISK_COUNT} -l 1 --assume-clean --name=boot `ls ${DISK_PART}[${DISK_NAMES}]2 | sort`
      mdadm -C /dev/md1 -v -f -R -n ${DISK_COUNT} -l 1 --assume-clean --name=boot2 `ls ${DISK_PART}[${DISK_NAMES}]3 | sort`
      mdadm -C /dev/md2 -v -f -R -n ${DISK_COUNT} -l $datalevel --assume-clean --name=${SYSTEM_NAME} `ls ${DISK_PART}[${DISK_NAMES}]5 | sort`

      sleep 5
    elif [ $DISK_COUNT -eq 1 ]; then
      BOOT=/dev/${DISK_PREFIX}da2
      BOOT2=/dev/${DISK_PREFIX}da3
      RAW_SYSTEM_NAME=${DISK_PREFIX}da5
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
    logger -t custom_part.sh disabled: Destroying existing volumes
    umount /target/boot
    umount /target
    umount /media
    swapoff /dev/${VG_NAME}/swap
    exit 1

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

