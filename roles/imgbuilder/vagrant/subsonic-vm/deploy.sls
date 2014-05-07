include:
  - .up

subsonic-vm-halt:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/subsonic-vm; vagrant halt
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: subsonic-vm-provision

subsonic-vm-detach:
  file.absent:
    - name: /mnt/images/templates/imgbuilder/subsonic-vm/.vagrant
    - require:
      - cmd: subsonic-vm-provision

subsonic-vm-move-network:
  cmd.run:
    - name: /mnt/images/templates/imgbuilder/scripts/def2bridge subsonic-vm_default br1
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: subsonic-vm-detach


subsonic-vm-copy-and-resize-storage:
  cmd.run:
    - name: libguestfs-tools /mnt/images/templates/imgbuilder/scripts/def2bridge subsonic-vm_default br1
if lv:
    recreate lv with final size

virsh dumpxml subsonic-vm_default | xpath -q -e /domain/devices/disk/source

virsh pool-list
virsh vol-create-as poolname newvol 10G
virt-resize image lvlg  --expand /dev/sda2 --LV-expand /dev/vg_guest/lv_root 
virt-resize image otherimage --resize /dev/sda2=final size --LV-expand /dev/vg_guest/lv_root 
virt-resize /mnt/images/default/subsonic-vm_default.img /dev/mapper/vg0-ttrss--vm_default --expand /dev/sda2  --LV-expand /dev/ubuntu1204-vg/root

    - user: imgbuilder
    - group: imgbuilder
   