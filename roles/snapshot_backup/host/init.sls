include:
  - imgbuilder

{#
roles.snapshot_backup.host.init
...............................
 - generate backup_vm: generate a "trusty_simple" plus salt install duply, duplicity, 
   - maybe modprobe acpiphp
   - modprobe pci_hotplug
   - for hotplug support
   - very simple disk: one partition disk virtual image (readonly if possible):
      boots from there, best readonly with temporary storage, and as something unusual like /vd10
      has salt installed and has some grains that are specific to the underlying machine
       eg. original minion so it can retrieve snapshot_config: backup
  - generate a cache volume for this machine, simple ext4 filesystem, but writeable for backup vm
#}

snapshot_backup_host:
  pkg.installed:
    - pkgs:
      - lvm2
      - xmlstarlet

{% if salt['pillar.get']('snapshot_backup:custom_storage', false) %}
    {% from 'storage/lib.sls' import storage_setup with context %}
    {{ storage_setup(salt['pillar.get']('snapshot_backup:custom_storage')) }}
{% endif %}

{% if "backup_vm" not in salt['virt.list']['local'] %}
    {% from "roles/imgbuilder/preseed/defaults.jinja" import defaults as ps_set with context %}
    {% from "roles/snapshot_backup/host/lib.sls" import create_backup_vm with context %}
    {% load_yaml as updates %}
    {% set hostname= "backup_vm" %}
target: '/mnt/images/templates/imgbuilder/{{ hostname }}'
hostname: {{ hostname }}
    {% endload %}
    {% do ps_set.update(updates) %}

    {{ create_backup_vm(ps_set) %}
    {{ start_backup_vm(ps_set) %}
{% endif %}


backup_vm_is_ready:
  cmd.run:
    - name: true
