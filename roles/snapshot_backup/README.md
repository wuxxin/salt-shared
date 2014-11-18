virtual machine based lvm snapshot backup and recovery using duplicity for backup
=================================================================================

Creates and spawns a backup vm that get LVM snapshots of other vm's by the hypervisor host, 
(automatically) attaches them as disks connected to vm,
so the vm can backup these lvm snapshots according to the desires of the original vm,
using duplicity to a target space (eg. ftp, ssh+sftp, s3)

In addition it can
  - backup the host system using lvm snapshots
  - run a backup on itself, not using snapshots
  - future: run a snapshot backup of a docker container

Setup:
------
  - for every minion(may be configured on the saltmaster in master.d/):
    -  returner.smtp_return must be configured for every minion targeted
  - on salt master: pillar item salt.reactor.includes must include "- roles.snapshot_backup"
  - on hypervisor host: pillar item 
    - schedule.snapshot_backup
    - snapshot_backup.host
  - for every minion that wants to be backuped: pillar item snapshot_backup.client must be configured

Workflow:
---------
  - roles.snapshot_backup.host is run on host
    - generates backup_vm

  - roles.snapshot_backup.client is run on client
    - emits reactor signal snapshot_backup/client/config-update
    - signal is received on hosts that match pillar "snapshot_backup:host:status:present"
      - add config update to /srv/snapshot_backup, backup config for client is saved

  - roles.snapshot_backup.host.backup_run is run on the host via the salt scheduler added to the host pillar
    - for every config in /srv/snapshot_backup/client
      - pre snapshot work
      - salt "backup.minion_id" state.sls onlyonce=true roles.snapshot_backup.backupvm.mount_and_duply target_minion.id
        pillar: snapshot_backup:run:config 
      - post snapshot work
    - return the findings and work results via returner.smtp_return

Convinience
-----------

salt-call state.sls roles.snapshot_backup.generate_cfg x=z z=e k=o l=i


Example Files:
--------------

backup-types:
  "lvm_libvirt"
  "lvm_host"
  "self"
  "plain"


hypervisor_pillar:
---
schedule:
  snapshot_backup:
    jid_include: True
    maxrunning: 1
    when: 3:30am
    returner: smtp_return
    function: state.sls
    args:
      - roles.snapshot_backup.host.backup_run
    kwargs:
      test: True

snapshot_backup:
  host:
    state: "present"
    config:
      data_container:
        name: "omoikane/backup_config_cache"
        attach_as: "vdy"
      duply:
        recipient_id: saltmaster@omoikane backup_snapshot@backupvm
        signing_id: backup_snapshot@backupvm
        signing_gpg_secret_asc: |
          whatever
        target: 'ftp://%(backup.username)s:%(backup.password)s@%(backup.host)s/%(duplicity.root)s'
        options:
          max_age: 2M
          max_fullbackups: 2
          duply_options: "whatever"
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

backupvm pillar:
---
snapshot_backup:
  backupvm:
    state: present

client pillar:
---
snapshot_backup:
  client:
    status: present
    config:
      type: "lvm_libvirt" {# get attached disks, snapshot all of them, and make available in backupvm, is default #}
      offline_ok: false {# do not backup if domain offline #}
      pre_snapshot: "backupninja -n && hot-snapshot-prepare.sh pause && sync"
      on_snapshot: "hot-snapshot-prepare.sh continue"
      post_snapshot: "echo 'success' > /var/run/snapshot_ok"
      pre_recovery: "echo 'installed blank machine is booted, prepare for restore and then shutdown' && shutdown"
      end_recovery: "echo 'this is if needed run in backupvm via chroot'"
      post_recovery: "echo 'data is overwritten, machine booted again, with data, after restore, now reintegrate data, start daemons if neccecary'"
      backup:
        mount: "vg0/host_root"
        source: "/"
        exclude: |
            bla
            blu

client pillar for hypervisor host itself: type="host_lvm", add host_device and target_device
--- 
snapshot_backup:
  client:
    status: "present"
    config:
      backup:
        type: "lvm_host" {# restricted to same host where snapshot_backup:host:present = True, backup_snapshot host will enforce this #}
        host_device: "omoikane/host_root" {# the lvm device we are going to make a snapshot from #}
        target_device: "vda" {# the desired target device name in the backupvm #}
        mount: "vda"
        source: "/"
        exclude:

client pillar for the backup vm itself: type="plain", omit "mount" 
--- 
snapshot_backup:
  client:
    status: "present"
    config:
      type: "plain" {# do not use libvirt for vm management, ignore lvm, just execute duply from local source #}
      backup: 
        source: "/mnt/backup_config_cache/config"
        exclude:
 
reactor-snapshot_backup-client-update pillar:
---
snapshot_backup:
  update:
    minion: {{ data.id }}
    config: 
      # normal client config comes here



Implementation Design
---------------------

roles.snapshot_backup.recovery:
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
