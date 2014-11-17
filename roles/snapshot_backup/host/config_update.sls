{% from "roles/snapshot_backup/defaults.jinja" import settings as s with context %}

{{ s.config_base }}/clients.d:
  file.directory:
    - makedirs: True

{% if salt['pillar.get']('snapshot_backup:update:config:type', 'libvirt-lvm') = "host-lvm" and 
      salt['pillar.get']('snapshot_backup:host:present', False) != True %} 
config_error:
  cmd.run:
    - name: false
{% else %}

{{ s.config_base }}/clients.d/{{ salt['pillar.get']('snapshot_backup:update:minion') }}:
  file.managed:
    - contents_pillar: "snapshot_backup:update:config"

{% endif %}
