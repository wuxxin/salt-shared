{% from "roles/snapshot_backup/defaults.jinja" import settings as s with context %}

{{ s.config_base }}/clients.d:
  file.directory:
    - makedirs: True

{% if salt['pillar.get']('snapshot_backup:update:config:type', 'lvm_libvirt') = 'lvm_host' and 
      salt['grains.get']('id', '') != salt['pillar.get']('snapshot_backup:update:minion') %} 
config_error:
  cmd.run:
    - name: echo "only snapshot-backup host can request a snapshot-backup config type of lvm_host"; exit 1
{% else %}

  {% if salt['pillar.get']('snapshot_backup:update:status', 'absent') = 'present' %} 

{{ s.config_base }}/clients.d/{{ salt['pillar.get']('snapshot_backup:update:minion') }}:
  file.managed:
    - contents_pillar: "snapshot_backup:update:config"

  {% else %}

{{ s.config_base }}/clients.d/{{ salt['pillar.get']('snapshot_backup:update:minion') }}:
  file.managed:
    - contents:
        absent: True

  {% endif %}
{% endif %}
