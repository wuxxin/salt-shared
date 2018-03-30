virtual machine based lvm snapshot backup and recovery using duplicity for backup
=================================================================================

 duplicity/borg need lots of temp space so put /tmp and /usr/tmp to the backup_config_cache

 make patch duplicity to add paramiko proxy command support:
   http://stackoverflow.com/questions/17681031/python-ssh-using-tor-proxy


Creates and spawns a backup vm that get LVM snapshots of other vm's by the hypervisor host,
(automatically) attaches them as disks connected to vm,
so the vm can backup these lvm snapshots according to the desires of the original vm,
using duplicity/borg to a target space (eg. ftp, ssh+sftp, s3)

In addition it can
  - backup the host system using lvm snapshots
  - run a backup on itself, not using snapshots
  - future: run a snapshot backup of a docker container

Requirements:
-------------
  - a libvirt capable host and lvm for snapshoting
  - a backup space (accessable via ssh/sftp or duplicity supported protocols)

Setup:
------
  - for every minion(may be configured on the saltmaster in master.d/):
    -  returner.smtp_return must be configured for every minion targeted
  - on salt master: pillar item salt.reactor.includes must include "- roles.snapshot-backup"
  - on hypervisor host: pillar item
    - schedule.snapshot-backup
    - snapshot-backup.host
  - for every minion that wants to be backuped: pillar item snapshot-backup.client must be configured

Convinience
...........

salt-call state.sls roles.snapshot-backup.generate_cfg ./ snapshot-backup@host z=e k=o l=i
  - can generate gpg keys and include them in a pillar file,
  - connect via ssh using password, makedir .ssh/authorized_keys
  - make stub directories (eg omoikane)


Workflow:
---------
  - roles.snapshot-backup.host is run on host
    - generates backup_vm

  - roles.snapshot-backup.client is run on client
    - emits reactor signal snapshot-backup/client/config-update
    - signal is received on hosts that match pillar "snapshot-backup:host:status:present"
      - add config update to /srv/snapshot-backup, backup config for client is saved

  - roles.snapshot-backup.host.backup_run is run on the host via the salt scheduler added to the host pillar
    - for every config in /srv/snapshot-backup/client
      - pre snapshot work
      - salt "backup.minion_id" state.sls onlyonce=true roles.snapshot-backup.backupvm.mount_and_backup target_minion.id
        pillar: snapshot-backup:run:config
      - post snapshot work
    - return the findings and work results via returner.smtp_return


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
  snapshot-backup:
    jid_include: True
    maxrunning: 1
    when: 3:30am
    returner: smtp_return
    function: state.sls
    args:
      - roles.snapshot-backup.host.backup_run
    kwargs:
      test: True

snapshot-backup:
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
          - require_in: "cmd: roles.snapshot-backup.host.ready"

backupvm pillar:
---
snapshot-backup:
  backupvm:
    state: present

client pillar:
---
snapshot-backup:
  client:
    status: present
    config:
      type: "lvm_libvirt" {# get attached disks, snapshot all of them, and make available in backupvm, is default #}
      offline_ok: false {# do not backup if domain offline #}
      pre_snapshot: "backupninja -n && hot-snapshot-prepare.sh pause && sync"
      on_snapshot: "hot-snapshot-prepare.sh continue"
      post_snapshot: "echo 'success' > /var/run/snapshot_ok"
      pre_recovery: "echo 'installed blank machine is booted, prepare for restore and then shutdown'"
      end_recovery: "echo 'this is, if needed, run in backupvm via chroot to target'"
      post_recovery: "echo 'data is overwritten, machine booted again, with data, after restore, now reintegrate data, start daemons if neccecary'"
      backup:
        mount: "vg0/host_root"
        source: "/"
        exclude: |
            bla
            blu

client pillar for hypervisor host itself: type="host_lvm", add host_device and target_device
---
snapshot-backup:
  client:
    status: "present"
    config:
      type: "lvm_host" {# restricted to same host where snapshot-backup:host:present = True, backup_snapshot host will enforce this #}
      backup:
        host_device: "omoikane/host_root" {# the lvm device we are going to make a snapshot from #}
        target_device: "vdb" {# the desired target device name in the backupvm #}
        mount: "vda"
        source: "/"
        exclude:

client pillar for the backup vm itself: type="plain", omit "mount"
---
snapshot-backup:
  client:
    status: "present"
    config:
      type: "plain" {# do not use libvirt for vm management, ignore lvm, just execute duply from local source #}
      backup:
        source: "/mnt/backup_config_cache/config"
        exclude:

reactor-snapshot-backup-client-update pillar:
---
snapshot-backup:
  update:
    minion: {{ data.id }}
    config:
      # normal client config comes here



      snapshot-backup.target.openwrt:
        * openwrt router software deployment with usb attached harddisk, listens on tor
        * so we can transport the backup back to a location

Implementation Design
---------------------

roles.snapshot-backup.recovery:
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
