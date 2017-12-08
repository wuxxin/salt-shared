# setup storage on running appliance, this is called from prepare-appliance

{% macro mount_setup(name) %}
mount-{{ name }}:
  mount.mounted:
    - name: /{{ name }}
    - device: /dev/disk/by-label/{{ name }}
    - mkmnt: true
    - fstype: ext4
    - onlyif: test -b /dev/disk/by-label/{{ name }} -a "$(blkid -p -s TYPE -o value /dev/disk/by-label/{{ name }})" == "ext4"
{% endmacro %}

{% macro dir_setup(base, dirlist, ignore_mountpoint) %}
  {% for (name, owner, mode) in dirlist %}
{{ base }}/{{ name }}:
  file.directory:
    - makedirs: True
    {% if owner %}
    - user: {{ owner }}
    - group: {{ owner }}
    {% endif %}
    {% if mode %}
    - dir_mode: {{ mode }}
    {% endif %}
    {% if not ignore_mountpoint %}
    - onlyif: mountpoint -q {{ base }}
    {% endif %}
  {% endfor %}
{% endmacro %}

{% macro relocate_setup(dirlist) %}
  {% for (name, source, pre, post) in dirlist %}
    {%- if pre %}
prefix_relocate_{{ source }}:
  cmd.run:
    - name: {{ pre }}
    - onlyif: test -d {{ name }} -a -e {{ source }} -a ! -L {{ source }}
    {%- endif %}
relocate_{{ source }}:
  file.rename:
    - name: {{ name }}
    - source: {{ source }}
    - force: true
    - onlyif: test -d {{ name }} -a -e {{ source }} -a ! -L {{ source }}
    {%- if pre %}
    - require:
      - cmd: prefix_relocate_{{ source }}
    {%- endif %}
symlink_{{ source }}:
  file.symlink:
    - name: {{ source }}
    - target: {{ name }}
    - onlyif: test -d {{ name }} -a ! -L {{ source }}
    {%- if pre %}
    - require:
      - file: relocate_{{ source }}
    {%- endif %}
    {%- if post %}
postfix_relocate_{{ source }}:
  cmd.run:
    - name: {{ post }}
    - onchanges:
      - file: relocate_{{ source }}
    {% endif %}
  {% endfor %}
{% endmacro %}


# ### custom Storage Setup
{% if (salt['pillar.get']("appliance:storage:mount:volatile", false) and
      salt['file.file_exists']('/dev/disk/by-label/volatile')) or
      (salt['pillar.get']("appliance:storage:mount:data", false) and
       salt['file.file_exists']('/dev/disk/by-label/data')) %}

  {% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(salt['pillar.get']("appliance:storage:setup", {})) }}
{% endif %}

# ### Volatile Setup
{% if not salt['pillar.get']("appliance:storage:mount:volatile",false) %}
{{ mount_setup('volatile') }}
{% endif %}

# TODO also include /tmp and var/tmp (have special different dir_mode)
{{ dir_setup ('/volatile', [
  ('docker', '', ''),
  ('backup-test', 'app', ''),
  ('duplicity', 'app',''),
  ('prometheus', 1000, ''),
  ('alertmanager', 1000, ''),
  ('grafana', 1000, ''),
  ], salt['pillar.get']("appliance:storage:mount:volatile",false)) }}

{{ relocate_setup([
  ('/volatile/docker', '/var/lib/docker',
    'systemctl stop cadvisor; docker kill $(docker ps -q); systemctl stop docker',
    'systemctl start docker; systemctl start cadvisor'),
  ('/volatile/prometheus', '/app/prometheus', '', ''),
  ('/volatile/alertmanager', '/app/alertmanager', '', ''),
  ('/volatile/grafana', '/app/grafana', '', ''),
  ('/volatile/duplicity', '/app/.cache/duplicity', '', ''),
  ]) }}

# ### Data Setup
{% if not salt['pillar.get']("appliance:storage:ignore:data",false) %}
{{ mount_setup('data') }}
{% endif %}

{{ dir_setup ('/data', [
  ('etc', 'app', ''),
  ('pgdump', 'app', ''),
  ('postgresql', 'postgres', ''),
  ], salt['pillar.get']("appliance:storage:ignore:data",false)) }}

{{ relocate_setup([
  ('/data/postgresql', '/var/lib/postgresql',
    'systemctl stop postgresql', 'systemctl start postgresql'),
  ('/data/etc', '/app/etc', '', ''),
  ]) }}
