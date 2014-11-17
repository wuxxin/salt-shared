include:
  - imgbuilder

snapshot_backup_host:
  pkg.installed:
    - pkgs:
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

install_backup_schedule:
