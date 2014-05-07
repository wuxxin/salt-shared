snapshot_backup:
  pkg.installed:
    - pkgs: 
      - xmlstarlet
      - duplicity
      - rdiff-backup


for x in `virsh dumpxml --inactive orion | xmlstarlet sel -I -t -m "domain//disk[@type='block']" -v "source/@dev" -n`; do
  vgp=${x%/*}; vg=${vgp##*/}; vn=${x##*/}; 
  if test "$vn" = "orion_root"; then 
    parts="1 -orion--vg-swap_1 orion--vg-root";
  else
    parts="disk"; 
  fi;
   ./snapshot start $vg $vn ${vn}_snap $parts; 
done

  execute for a in backup.volumes: lvm create -s name_of(a).
  execute for a in snapshot(backup.volumes): add devices of partitions
  execute for a in partitions(backup.partitions): mount them readonly
  execute rdiff-backup to jupiter as user@milky to backup partition_snapshot_volumes

at end of all runs:
  execute duplicity to hetzner as user@bla to backup /mnt/backup_data --exclude rdiff-deltas

jupiter: virtual machine with
 vda: little
 vdb: big (300G?)

