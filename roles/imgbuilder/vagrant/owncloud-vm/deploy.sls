owncloud-vm-halt:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/owncloud-vm; vagrant halt
    - user: imgbuilder
    - group: imgbuilder
#    - require:
#      - cmd: owncloud-vm-provision

owncloud-vm-detach:
  file.absent:
    - name: /mnt/images/templates/imgbuilder/owncloud-vm/.vagrant
    - require:
      - cmd: owncloud-vm-halt

owncloud-vm-move-network:
  cmd.run:
    - name: /mnt/images/templates/imgbuilder/scripts/def2bridge owncloud-vm_default br1
    - require:
      - file: owncloud-vm-detach


#owncloud-vm-copy-and-resize-storage:
#  cmd.run:
#    - name: libguestfs-tools
#    - user: imgbuilder
#    - group: imgbuilder
#    - require:
#      - cmd: owncloud-vm-move-network

#if lv:
#    recreate lv with final size
#
#virsh dumpxml owncloud-vm_default | xpath -q -e /domain/devices/disk/source
#
#virsh pool-list
#virsh vol-create-as poolname newvol 10G
#virt-resize image lvlg  --expand /dev/sda2 --LV-expand /dev/vg_guest/lv_root 
#virt-resize image otherimage --resize /dev/sda2=final size --LV-expand /dev/vg_guest/lv_root 
#virt-resize /mnt/images/default/owncloud-vm_default.img /dev/mapper/vg0-owncloud--vm_default --expand /dev/sda2  --LV-expand /dev/ubuntu1204-vg/root

   