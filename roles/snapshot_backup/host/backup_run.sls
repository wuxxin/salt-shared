snapshot_backup_run:
  cmd.run:
    - name: false
{#
stop_delay_timer stop_backup_vm
if not running:
  cloud.start backup_vm minion_id

for each configured backup run do
  salt "minion_id" cmd.run config.pre_snapshot
  salt.cloud "minion_id" pause
  for x in lvm volumes connected to minion id  do
    snapshot begin x
  salt.cloud "minion_id" unpause
  salt "minion_id" cmd.run config.on_snapshot
  attach_disk x to backup_vm
  attach_disk backupvm_cache_volume to backup_vm
  salt "backup-minion-id" state.sls onlyonce=true roles.snapshot_backup.mount_and_backup target_minion.id
  start_delay_timer 10m stop_backup_vm cloud.stop backup_vm minion_id # will call the cmd within 10minutes if not aborted
  detach all lvm volumes of minion_id
  detach cache_volume
  snapshot delete
  salt "minion_id" cmd.run config.post_snapshot


snippets:
.........

 * find out all file backing images of a domain:
for a in `virsh dumpxml --inactive $id |
  xmlstarlet sel -I -t -m "domain//disk[@type='file']" -v "source/@file" -o " " -v "target/@dev" -n`; do
  echo "prints out file and target dev: $a"
 * find out all lvm backing images of a domain:
for a in `virsh dumpxml --inactive $id |
  xmlstarlet sel -I -t -m "domain//disk[@type='block']" -v "source/@dev" -o " " -v "target/@dev" -n `; do
  echo "prints out lvm volume and target dev: $a"
 * attach a file backing volume to a domain:
cat << EOF
<disk type='file' device='disk'>
  <driver name='' type='qcow2' />
  <source file='$a'/>
  <target dev='vd$(hardiskletter)' bus='virtio'/>
</disk>
| virsh attach-device $domainid
 * attach a snapshot lvm volume to a domain

cpu and io nicing:

${GHE_NICE:="nice -n 19"}
${GHE_IONICE:="ionice -c 3"}
#}
