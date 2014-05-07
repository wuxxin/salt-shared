#!/bin/bash

cd output-qemu
name=`ls *.qcow2`
name=${name%%.qcow2}
qemu-img convert -c -O qcow2 $name.qcow2 box.img
cp ../vagrant_defaults/metadata.json .
cp ../vagrant_defaults/Vagrantfile .
tar cvzf $name.box ./metadata.json ./Vagrantfile ./box.img
vagrant box add $name $name.box --provider libvirt
e=$?
if test $? -eq 0; then
  cd ..
  rm  -r output-qemu
else
  cd ..
  exit $e
fi
