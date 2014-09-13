#!/bin/bash

qemu-img create -f qcow2 empty.qcow2 11g
name=`ls *.qcow2`
name=${name%%.qcow2}
qemu-img convert -c -O qcow2 $name.qcow2 box.img
tar cvzf $name.box ./metadata.json ./Vagrantfile ./box.img
vagrant box add $name $name.box --provider libvirt
e=$?
if test $? -eq 0; then
  rm  box.img $name.box empty.qcow2
else
  cd ..
  exit $e
fi
