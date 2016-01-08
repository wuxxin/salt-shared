#! /bin/bash

snapshotcreate() {
    # Args: $1= orgdev, $2 = shotvol  $3 = shotsize
    echo "Taking snapshot from $1 as $2 with size $3"
    /sbin/lvcreate -s --name $2 --size $3 $1
    iserr=$?

    if test 0 -eq $iserr ; then
       echo "Snapshot activated"
    else
       echo "ERROR: Error activating snapshot, lvcreate exited with $iserr"
       exit $iserr
    fi
}

snapshotremove() {
    # Args: $1 shotdev
    echo "Removing the snapshot device $1"
    /sbin/lvremove -f $1
    iserr=$?

    if test 0 -eq $iserr ; then
       echo "Snapshot deactivated"
    else
       echo "ERROR: Error deactivating snapshot, lvremove exited with $iserr"
       exit $iserr
    fi

}

verifymount() {
    # Args: $1=Shotmount
    # Verify the Mount Point exists, if not, create it
    if ! test -d "$1" ; then
        mkdir -p $1
        # Verify the Mount Point was created, if not exit
        if ! test -d "$1" ; then
            echo "ERROR: Could not create the mountpoint directory ($1)"
            exit 1
        fi
    fi
}

issafeimage() {
    # Args: $1 shotdev
    echo "Testing snapshot device $1 for compatibility"
    ourlvm="vg0"
    echo "ERROR: not yet implemented!"

}


snapshotmount() {
    # Args: $1=shotdev , $2=shotmount, $3=mount options (default to "-o ro")
    SHOTDEV=$1
    SHOTMOUNT=$2
    if test "$3" = ""; then
        MOUNTPARAM="-o ro"
    else
        MOUNTPARAM=$3
    fi

    echo "Mount $SHOTDEV to the Mount Point $SHOTMOUNT using $MOUNTPARAM"
    mount $MOUNTPARAM $SHOTDEV $SHOTMOUNT
    iserr=$?

    if test 0 -eq $iserr ; then
        echo "Snapshot partition mounted"
    else
        echo "ERROR: Error mounting snapshot partition, mount exited with $iserr"
        exit $iserr
    fi
}

snapshotunmount() {
    # Args: $1=shotmount
    echo "Umounting Snapshot Volume $1"
    umount $1
}


MOUNTBASE=/mnt
SHOTSIZE=6G
command=$1
shift

if test "$command" = "status"; then
    mount | grep $1
    exit 0
fi

if test "$command" != "start" -a "$command" != "stop" -a "$command" != "info"; then
    echo "Error: Wrong usage." 1>&2
    cat << EOF
Usage: $0
  status snapshotname
  info  volumegroup volumename snapshotname
  start volumegroup volumename snapshotname [([-]"disk")|([-](partition-number)|(logical-volume-name))*]
  stop  volumegroup volumename snapshotname [([-]"disk")|([-](partition-number)|(logical-volume-name))*]

"disk":
  whole volume is a filesystem, no partitions are used
"-" before partition-number, logical-volume-name or "disk":
  do not mount/unmount,
  remove from device-mapper before stopping snapshot if a recursive logical-volume
EOF
    exit 1
fi

LVMVG=$1
ORGVOL=$2
SNAPVOL=$3
shift 3
SNAPPART=$*
if test "$SNAPPART" = ""; then SNAPPART="disk"; fi

echo "LVMVG=$LVMVG , ORGVOL=$ORGVOL , SNAPVOL=$SNAPVOL , SNAPPART=$SNAPPART"

if test "$command" = "info"; then
    echo "info at `date`"
    snapshotcreate ${LVMVG}/${ORGVOL} ${SNAPVOL} ${SHOTSIZE}
    /sbin/kpartx -l -v /dev/mapper/${LVMVG}-${SNAPVOL}
    snapshotremove ${LVMVG}/${SNAPVOL}
fi

if test "$command" = "start"; then
    echo "startsnapshot at `date`"

    for a in $SNAPPART; do
        verifymount ${MOUNTBASE}/${SNAPVOL}_${a}
    done

    snapshotcreate ${LVMVG}/${ORGVOL} ${SNAPVOL} ${SHOTSIZE}
    if test "$SNAPPART" = "disk"; then
      snapshotmount /dev/mapper/${LVMVG}-${SNAPVOL} ${MOUNTBASE}/${SNAPVOL}_${SNAPPART}
    else
      echo "test if there is a mdadm or an lvm partition inside the snapshot, if yes, test if setup (eg. names) collide, abort if"
      issafeimage /dev/mapper/${LVMVG}-${SNAPVOL}
      echo "add partitions of /dev/mapper/${LVMVG}-${SNAPVOL}"
      /sbin/kpartx -a /dev/mapper/${LVMVG}-${SNAPVOL}
      sleep 1

      for a in $SNAPPART; do

        if test "${a:0:1}" != "-";  then # if "-"as first character do not mount
          # test if there is a "-" inside a
          b=${a//[^-]/}
          if test "${b:0:1}" = "-"; then
            snapshotmount /dev/mapper/${a} ${MOUNTBASE}/${SNAPVOL}_${a}
          else
            snapshotmount /dev/mapper/${LVMVG}-${SNAPVOL}${a} ${MOUNTBASE}/${SNAPVOL}_${a}
          fi
        fi
      done
    fi
fi

if test "$command" = "stop"; then
    echo "stopsnapshot at `date`"

    if test "$SNAPPART" = "disk"; then
      snapshotunmount ${MOUNTBASE}/${SNAPVOL}_${SNAPPART}
    else
      for a in $SNAPPART; do
        if test "${a:0:1}" = "-";  then
          a=${a:1}
          # remove "-" as first char (for correct mapper removal)
        else
          snapshotunmount ${MOUNTBASE}/${SNAPVOL}_${a}
        fi
        # test if there is a "-" inside a, its a recursive logical volume
        b=${a//[^-]/}
        if test "${b:0:1}" = "-"; then
          dmsetup remove /dev/mapper/${a}
        fi

      done

      echo "remove partitions of /dev/${LVMVG}/${SNAPVOL}"
      /sbin/kpartx -d /dev/mapper/${LVMVG}-${SNAPVOL}
    fi

    snapshotremove ${LVMVG}/${SNAPVOL}
fi
