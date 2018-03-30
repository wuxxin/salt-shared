#!/bin/bash

msub() {
  python -c "import sys, re; sys.stdout.write(re.sub(r'$1', r'$2', sys.stdin.read(), flags=re.MULTILINE + re.DOTALL))"
}

prog=`echo $(cd $(dirname "$0") && pwd -L)/$(basename "$0")`
dir=`dirname $prog`
name=`basename $dir`

if test "$2" == ""; then
  cat <<EOF
usage: $0 machineid lvmgroup [--qcow2] [disksize]

for every filetype disk of a libvirt machine,
create a lvm volume of same maximal size,
copies data to target volume while throttling write to 10MB per second,
unlink old, link new volume to libvirt machine

optional parameter qcow2 makes the lvm volume type of "QCOW2" instead of "RAW"
optional parameter disksize (WIP): manual set a new size
(can not be smaller than qcow2 max size)


EOF
  exit 1
fi

libvirt_id=$1
libvirt_name=`virsh dumpxml $libvirt_id --migratable | xmlstarlet sel -t -v "domain/name"`
lvm_group=$2
output_type=raw
if test "$3" == "--qcow2"; then
  shift
  output_type=qcow2
fi
disk_size=$3
our_pid=$$

# create a blkio group
throttle_bytes="104857" # 1 MB
throttle_group="imagemove"
cgcreate -g blkio:$throttle_group

echo "l_id: $libvirt_id , l_name: $libvirt_name , lvm_group: $lvm_group , our_pid: $our_pid"
echo "`virsh dumpxml $libvirt_id --migratable`"
ls /sys/fs/cgroup/blkio/
read answer

# for each of the configured disks in the libvirt xml file
for disk in `virsh dumpxml $libvirt_id --migratable | xmlstarlet sel -I -t -m "domain//disk[@type='file']" -v "source/@file"  -o ":" -v "target/@dev" -n`; do
  disk_file="${disk%%:*}"
  disk_dev="${disk##*:}"
  lvm_volume=${libvirt_name}.${disk_dev}

  # calculate needed disk size
  disk_size_response=`qemu-img info "$disk_file" | grep virtual.size`
  disk_size=`echo "$disk_size_response" | sed -re "s/virtual.size:.[0-9.]+[KMGT].\(([0-9]+).bytes\)/\\1/g"`

  echo "d_file: $disk_file , d_dev: $disk_dev , lvm_volume: $lvm_volume , d_size_r: $disk_size_response , d_size: $disk_size"
  read answer

  # create lvm volume
  lvcreate --name $lvm_volume --size ${disk_size}b $lvm_group
  vmm_resp=$(stat -c '%t:%T' `readlink -e /dev/mapper/${lvm_group}-${lvm_volume} `)
  vol_maj_min=$(printf "%d:%d\n" 0x${vmm_resp%%:*} 0x${vmm_resp##*:})

  # start write throtteling to created lvm device
  echo "vmm_resp: $vmm_resp , vol_maj_min: $vol_maj_min , throttle_bytes: $throttle_bytes"
  read answer
  echo "$vol_maj_min $throttle_bytes" > /sys/fs/cgroup/blkio/$throttle_group/blkio.throttle.write_bps_device

  # detach original disk from domain
  #virsh detach-disk --domain $libvirt_id --target $disk_file --config

  # copy/convert disk to lvm volume
  cgexec -g blkio:$throttle_group qemu-img convert -O $output_type  $disk_file /dev/mapper/${lvm_group}-${lvm_volume}
  err=$?

  # remove throtteling
  cgremove blockio:$throttle_group

  if test -z $err; then

    echo "next is attach"
    read answer

    # atach new disk to domain
    virsh attach-disk --domain $libvirt_id --source /dev/mapper/${lvm_group}-${lvm_volume} --target $disk_dev

    # remove from storage
    #virsh vol-remove
  fi
done
