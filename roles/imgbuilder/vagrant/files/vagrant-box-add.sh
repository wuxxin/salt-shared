#!/bin/bash

myprog=`echo $(cd $(dirname "$0") && pwd -L)/$(basename "$0")`
mydir=`dirname $myprog`
name=`basename $mydir`

size_parsed=`echo "$name" | grep -E -o -- "^.+-[0-9]+[gG]{1}$"`
image_size=13g

if test "$size_parsed" != ""; then
  image_size=`echo "$name" | sed -re "s/^.+-([0-9]+[gG])$/\\1/g"`
fi
if test "$1" != ""; then
  image_size=$1
fi

image_size_nr=${image_size:0:-1}
echo "Name,size_parsed,Imgsize, size: $name:$size_parsed:$image_size:$image_size_nr"

qemu-img create -f qcow2 $name.qcow2 $image_size
qemu-img convert -c -O qcow2 $name.qcow2 box.img

cat > ./metadata.json << EOF
{
  "provider" : "libvirt",
  "format" : "qcow2",
  "virtual_size" : $image_size_nr
}
EOF

tar cvzf $name.box ./metadata.json ./Vagrantfile ./box.img
vagrant box add $name $name.box --provider libvirt
e=$?
if test $? -eq 0; then
  rm  box.img $name.box $name.qcow2 metadata.json
else
  exit $e
fi
