#!/bin/bash

image_size=22g
if test "$1" != ""; then
    image_size=$1
fi
qemu-img create -f qcow2 empty-22g.qcow2 $image_size
name=`ls *.qcow2`
name=${name%%.qcow2}
qemu-img convert -c -O qcow2 $name.qcow2 box.img

tar cvzf $name.box ./metadata.json ./Vagrantfile ./box.img
vagrant box add $name $name.box --provider libvirt
e=$?
if test $? -eq 0; then
  rm  box.img $name.box empty-22g.qcow2
else
  cd ..
  exit $e
fi
