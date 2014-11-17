salt master based snapshot backup and recovery 

Creates and Spawns a backup_vm that gets LVM snapshots of other vm's 
(automatically) attached  as disks connected to vm,
can backup these lvm snapshots according to the desires of the vm.
 - can backup the backup_vm itself (duply config)
 - can backup the host system

roles.snapshot_backup.
  host
    . generate_backup_vm
    . scheduled_backup_runner
    . reactor event-target: snapshot_backup_config_update
  backup_vm
    . mount_and_duply
  client

Workflow:
 roles.snapshot_backup.host is run on host
   generates backup_vm
 roles.snapshot_backup.client is run on client
   emits snapshot_backup_config_update
 roles.snapshot_baclup.scheduled_backup_runner
   for every config:
      prework
      salt "backup.minion_id" state.sls onlyonce=true roles.snapshot_backup.backup_vm.mount_and_duply target_minion.id
      postwork

hypervisor_pillar:
---
snapshot_backup:
  host:
    state: "present"
    data:
      volume: "omoikane/backup_config_cache"
      attach_as: "vdy"
    custom_storage:
      lvm:
        lv:
          - name "backup_config_cache"
          - size "10g"
        format:
          - name
          - type: "ext4"
          - opts: "xattr"
          - require_in: "cmd: roles.snapshot_backup.host.ready"

backup_vm pillar:
---
snapshot_backup:
  backup_vm:
    state: present
    recipient_id: saltmaster@omoikane backup_snapshot@backupvm
    signing_id: backup_snapshot@backupvm
    signing_gpg_secret_asc: |
        whatever
    target: 'ftp://%(backup.username)s:%(backup.password)s@%(backup.host)s/%(duplicity.root)s'
    options:
      max_age: 2M
      max_fullbackups: 2
      duply_options: "whatever"

client-vm pillar:
this will call state roles.snapshot_backup.client,
  which emits "snapshot_config_update" as minion with self minion id
---
snapshot_backup:
  client:
    status: present
    type: "libvirt_lvm" {# get attached disks, snapshot all of them, and make available in backup_vm #}
    offline_ok: false {# do not backup if domain offline #}
    pre_snapshot:
      - "backupninja -n"
      - "hot-snapshot-prepare.sh  pause"
      - "sync"
    on_snapshot:
      - "hot-snapshot-prepare.sh continue"
    post_snapshot:
      - "echo 'success' > /var/run/snapshot_ok
    pre_recovery:
      - "echo 'installed but with blank data  machine is booted and then shutdown, make it possible to restore data, eg. delete some default files, or prevent daemons from starting after restore'"
      - "shutdown"
    end_recovery:
      - "this is if needed run in backupvm via chroot"
    post_recovery:
      - "echo 'data is overwritten, machine is booted again, with loaded data, after restore, now reintegrate data, start daemons if neccecary'
    backup:
      mount: "vg0/host_root"
      source: "/"
      exclude: |
          bla
          blu

--- client pillar for hypervisor host itself: 
    type="host_lvm", add host_device (for snapshot), target_device (for backup_vm), and mount
snapshot_backup:
  client:
    status: "present"
    backup:
      type: "host_lvm"
      host_device: "omoikane/host_root"
      target_device: "vda"
      mount: "vda"
      source: "/"
      exclude:

--- client pillar for the backup vm itself: type="self", omit "mount" 
snapshot_backup:
  client:
    status: "present"
    type: "self"
    backup: 
      source: "/mnt/backup_config_cache/config"
      exclude:


salt master:
------------
 - generate backup_vm: generate a "trusty_simple" plus salt install duply, duplicity, 
   - maybe modprobe acpiphp
   - modprobe pci_hotplug
   - for hotplug support
   - very simple disk: one partition disk virtual image (readonly if possible):
      boots from there, best readonly with temporary storage, and as something unusual like /vd10
      has salt installed and has some grains that are specific to the underlying machine
       eg. original minion so it can retrieve snapshot_config: backup
  - generate a cache volume for this machine, simple ext4 filesystem, but writeable for backup vm

schedule config
----
schedule:
  backup_runner:
    fuction: master-backup-runner
    jid_include: true
    hours: 24

one-runner
    args:
      - backup_vm
      - roles.snapshot_backup.backup_run


roles.snapshot_backup.master-backup-runner
----

for each configured backup run do

  salt "minion_id" cmd.run config.pre_snapshot
  salt.cloud "minion_id" pause
  for x in lvm volumes connected to minion id  do
    snapshot begin x
  salt.cloud "minion_id" unpause
  salt "minion_id" cmd.run config.on_snapshot
  attach_disk x to backup_vm
  attach_disk backupvm_cache_volume to backup_vm

  stop_delay_timer stop_backup_vm
  if not running:
    cloud.start backup_vm minion_id
  salt "backup.minion_id" state.sls onlyonce=true roles.snapshot_backup.mount_and_duply target_minion.id
    mount access to a file share or a lvm filesystem volume 
        (backupvm_cache_volume with write access, 
        for storing duplicity cache files (--archive-dir --name ),
        duply config files)
    mdadm --assemble --scan # assemble raid 
    lvchange something # and lvm
    mount -ro something /target/something
    update duply config from salt to duply_config dir
    run duply
    unmount everthing we can
    emit snapshot done target_minion.id result
  start_delay_timer 10m stop_backup_vm cloud.stop backup_vm minion_id # will call the cmd within 10minutes if not aborted


detach all lvm volumes of minion_id
detach cache_volume
snapshot delete
salt "minion_id" cmd.run config.post_snapshot


recovery:
.........

create machine using pillar vagrant and reboot into final stage, including salt minion running but empty
salt "minion_id" cmd.run config.pre_recovery
salt "minion_id" shutdown
attach disks to backup_vm
attach cache_volume to backup_vm
cloud.start backup_vm minion_id recovery
  mount access to a file share or a lvm filesystem volume with exklusive write access
  assamble device in backupvm
  * get original_minionid
  * get snapshot_config:backup
  * mount device to somewhere
  * update duply config from salt
  * run duply restore
runn config.end_recovery
unmount everything 
shutdown

detach all lvm volumes of minion_id from backup_vm
detach cache volume
cloud.start minion_id
salt "minion_id" cmd.run config.post_recovery


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
