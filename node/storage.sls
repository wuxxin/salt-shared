{% from "node/defaults.jinja" import settings %}

include:
  - .hostname
  - .accounts
{%- if settings.storage.filesystem.zfs|d(false) %}
  - zfs

{# if there are any storage.filesystem.zfs entries,
  depend on the zfs.sls state completed storage.filesystem.zfs entries are set #}
zfs_requisites:
  test:
    - nop
    - require:
      - sls: zfs
    - require_in:
      - zfs_fs_present_all
{%- endif %}

zfs_fs_present_all:
  test:
    - nop
lvm_fs_present_all:
  test:
    - nop
mounted_fs_all:
  test:
    - nop
directory_all:
  test:
    - nop

{%- if settings.storage is defined %}

  {%- if settings.storage.filesystem is defined %}
    {%- for fs in settings.storage.filesystem.zfs|d([]) %}
zfs_fs_present_{{ fs.name }}:
  zfs.filesystem_present:
    - name: {{ fs.name }}
      {%- for name,value in fs.items() %}
        {%- if name != 'name' %}
    - {{ name }}: {{ value }}
        {%- endif %}
      {%- endfor %}
    - require_in:
      - test: zfs_fs_present_all
    {%- endfor %}

    {% for fs in settings.storage.filesystem.lvm|d([]) %}
lvm_fs_present_{{ fs.name }}:
  lvm.lv_present:
    - name: {{ fs.name }}
      {%- for name,value in fs.items() %}
        {%- if name not in ['name', 'fs_type']%}
    - {{ name }}: {{ value }}
        {%- endif %}
      {%- endfor %}
    - require:
      - test: zfs_fs_present_all
    - require_in:
      - lvm: lvm_fs_present_all
      {%- if fs.fs_type is defined and fs.vgname is defined %}
  cmd.run:
    - name: mkfs.{{ fs.fs_type }} /dev/{{ fs.vgname }}/{{ fs.name }}
    - onlyif: test "$(blkid -p -s TYPE -o value /dev/{{ fs.vgname }}/{{ fs.name }})" == ""
    - onchanges:
      - lvm: lvm_fs_present_{{ fs.name }}
    - require:
      - lvm: lvm_fs_present_{{ fs.name }}
    - require_in:
      - lvm: lvm_fs_present_all
      {%- endif %}
    {%- endfor %}
  {%- endif %}

  {%- if settings.storage.mount is defined %}
    {% for m in settings.storage.mount|d([]) %}
mounted_fs_{{ m.name }}:
  mount.mounted:
    - name: {{ m.name }}
    - persist: true
    - mkmnt: true
      {%- for name,value in m.items() %}
        {%- if name != 'name' %}
    - {{ name }}: {{ value }}
        {%- endif %}
      {%- endfor %}
    - require:
      - test: lvm_fs_present_all
    - require_in:
      - test: mounted_fs_all
    {%- endfor %}
  {%- endif %}

  {%- if settings.storage.directory is defined %}
    {% for d in settings.storage.directory|d([]) %}
directory_{{ d.name }}:
  file.directory:
    - name: {{ d.name }}
    - makedirs: true
      {%- for name,value in d.items() %}
        {%- if name != 'name' %}
    - {{ name }}: {{ value }}
        {%- endif %}
      {%- endfor %}
    - require_in:
      - test: directory_all
    - require:
      - test: mounted_fs_all
    {%- endfor %}
  {%- endif %}

{%- endif %}
