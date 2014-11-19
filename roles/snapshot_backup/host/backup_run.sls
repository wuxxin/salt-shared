{% from "roles/snapshot_backup/defaults.jinja" import settings as s with context %}

stop_delaytimer:
  cmd.run:
    - name: true

{% if s.backup_vm_name not in salt['virt.list_active']['local'] %} 
start_backup_vm:
  module.run:
    - name: virt.start
    - m_name: {{ s.backup_vm_name }}
{% endif %}

transfer_backupvm_config:
  salt.state:
    - tgt: {{ s.backup_vm_name }}
    - sls: roles.snapshot_backup.backupvm.put_backupvm_config
    - pillar: 
        snapshot_backup:
          base_config: {{ salt['pillar.get']('snapshot_backup:host:config')|json }}
          client_config:
{%- for a in salt['cmd.run_stdout']('find '+ s.config_base+ '/clients.d/ -maxdepth 1 -type d -printf "%f\n"') %}
            {{ a }}: {{ salt['cmd.run_stdout']('cat '+ s.config_base+ '/clients.d/'+ a)|load_yaml|json }}
{%- endfor %}

{% for a in salt['cmd.run_stdout']('find '+ s.config_base+ '/clients.d/ -maxdepth 1 -type d -printf "%f\n"') %}
{% set client=a %}
{% set client_config= salt['cmd.run_stdout']('cat '+ s.config_base+ '/clients.d/'+ a)|load_yaml }}
{% if not defined client_config['absent'] %}

{% set client_disks= salt['cmd.run_stdout'](
'virsh dumpxml --inactive {{ client }} |
 xmlstarlet sel -I -t -m "domain//disk[@type='block']" -v "source/@dev" -o ":" -n -o "  " -v "target/@dev" -n')|load_yaml %}

config-pre_snapshot-{{ client }}:
  salt.function:
    - tgt: {{ client }}
    - name: cmd.run
    - m_name: "{{ client_config.pre_snapshot|d('true') }}"

libvirt-{{ client }}-pause:
  module.run:
    - name: virt.pause
    - vm: {{ client }}
    - require:
      - cmd: config-pre_snapshot-{{ client }}

{% for d,t in client_disks.iteritems() %}
lvm-snapshot-{{ d }}:
  module.run:
    - name: lvm.lvcreate
    - lvname: {{ d }}_snapshot
    - vgname: omoikane {# fixme: need default vg here #}
    - size: s.snapshot_size
    - snapshot: {{ d }}
    - require:
      - module: libvirt-{{ client }}-pause
    - require_in:
      - module: libvirt-{{ client }}-resume
{% endfor %}

libvirt-{{ client }}-resume:
  module.run:
    - name: virt.resume
    - vm: {{ client }}

config-on_snapshot-{{ client }}:
  salt.function:
    - tgt: {{ client }}
    - name: cmd.run
    - m_name: "{{ client_config.on_snapshot|d('true') }}"

{% for d,t in client_disks.iteritems() %}
attach_disk-{{ d }}:
{% endfor %}
  
mount-and-backup-{{ client }}:
  salt.state:
    - tgt: {{ s.backup_vm_name }}
    - sls: roles.snapshot_backup.backupvm.mount_and_backup
    - pillar:
        snapshot_backup:
          run: {{ client }}

{% for d,t in client_disks.iteritems() %}
detach_disk-{{ d }}:
    - require:
      - cmd: mount-and-backup-{{ client }}

lvm-remove-snapshot-{{ d }}:
  module.run:
    - name: lvm.lvremove
    - lvname: {{ d }}_snapshot
    - vgname: omoikane {# fixme: need default vg here #}
    - require:
      - module: detach_disk-{{ d }}
    - require_in:
      - cmd: config-post_snapshot-{{ client }}
{% endfor %}

{% endif %}
{% endfor %}

config-post_snapshot-{{ client }}:
  salt.function:
    - tgt: {{ client }}
    - name: cmd.run
    - m_name: "{{ client_config.post_snapshot|d('true') }}"
    - require_in:
      - cmd: start_delaytimer

{% endfor %}

start_delaytimer:
  cmd.run:
    - name: true

{# 

for each configured backup run do
  salt "minion_id" cmd.run config.pre_snapshot
  salt.cloud "minion_id" pause
  for x in lvm volumes connected to minion id  do
    snapshot begin x
  salt.cloud "minion_id" unpause
  salt "minion_id" cmd.run config.on_snapshot
  attach_disk x to backup_vm
  salt "backup-minion-id" state.sls onlyonce=true roles.snapshot_backup.mount_and_backup target_minion.id
  detach all lvm volumes of minion_id
  snapshot delete
  start_delay_timer 10m stop_backup_vm cloud.stop backup_vm minion_id # will call the cmd within 10minutes if not aborted
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
