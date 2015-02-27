#!/bin/bash

msub() {
  python -c "import sys, re; sys.stdout.write(re.sub(r'$1', r'$2', sys.stdin.read(), flags=re.MULTILINE + re.DOTALL))"
}

prog=`echo $(cd $(dirname "$0") && pwd -L)/$(basename "$0")`
dir=`dirname $prog`
name=`basename $dir`

if test "$3" == ""; then
  echo "usage: $0 xmlfile lvmgroup fqdn"
  exit 1
fi

xmlfile=$1
lvm_group=$2
fqdn=$3
disk_size=$4
our_pid=$!
throttle_bytes="10485760" # 10 MB

mkdir /sys/fs/cgroup/blkio/10mbwritepersecond
echo $our_pid > /sys/fs/cgroup/blkio/10mbpersecond/tasks

for disk in `cat $xmlfile | xmlstarlet sel -I -t -m "domain//disk[@type='file']" -v "source/@file"  -o ":" -v "target/@dev" -n`; do
  disk_file="${disk##:*}"
  disk_dev="${disk%%*:}"
  lvm_volume=$fqdn.$disk_dev

  disk_size_response=`qemu-img info "$disk_file" | grep virtual.size`
  disk_size=`echo "$disk_size_response" | sed -re "s/virtual.size:.[0-9.]+[KMGT].\(([0-9]+).bytes\)/\\1/g"`

  lvcreate --name $lvm_volume --size ${disk_size}b $lvm_group
  #virsh vol-create-as poolname newvol 10G
  echo "/dev/mapper/${lvm_volume}-${lvm_volume} $throttle_bytes" > /sys/fs/cgroup/blkio/10mbwritepersecond/blkio.throttle.write_bps_device

  qemu-img convert -f qcow2 -O raw $disk_file /dev/mapper/${lvm_volume}-${lvm_volume}

  # remove throtteling
  # remove old disk_file
done

# remove old file_harddisks from xml and add new lvm_harddisks to xml

    
