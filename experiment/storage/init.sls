# parted
#######

{% if salt['pillar.get']('storage:parted', {}) %}
parted:
  pkg.installed

{% for item, data in pillar.storage.parted.iteritems() %}

{% set part_label = 'gpt' if data.label|d('') else data.label %}
{% set blkid_label = 'dos' if part_label == 'msdos' else part_label %}

"parted-{{ item }}":
  cmd.run:
    - name: parted --script {{ item }} mklabel {{ part_label }}
    - onlyif: 'test "$(blkid -p -s PTTYPE -o value {{ item }})" == ""'
    - unless: 'test "$(blkid -p -s PTTYPE -o value {{ item }})" == "{{ blkid_label }}"'
    - require:
      - pkg: parted

{% if data.parts|d('') %}
{% for part in data.parts %}

{% set flags= [] %}
{% if part.flags is defined %}
{% for flagname in part.flags %}
{% do flags.append("set "+ part.number|string+ " "+ flagname+ " on") %}
{% endfor %}
{% endif %}

"parted-{{ item }}-p{{ part.number|string }}":
  cmd.run:
    - name: parted --align optimal --script {{ item }} mkpart P{{ part.number|string }} {{ part.start }} {{ part.end }} {{ flags|join(' ') }}
    - onlyif: 'test -b {{ item }}{{ part.number|string }})"'
    - require:
      - pkg: parted
      - cmd: "parted-{{ item }}"

{% endfor %}
{% endif %}

{% endfor %}

{% endif %}


# mdadm
#######
{% if salt['pillar.get']('storage:mdadm', {}) %}

mdadm:
  pkg.installed

{% for item, data in pillar.storage.mdadm.iteritems() %}
"mdadm-raid-{{ item }}":
  raid.present:
    - name: {{ item }}
    - opts:
{% for sub in data %}
      - {{ sub }}
{% endfor %}
    - require:
      - pkg: mdadm
{% endfor %}

{% endif %}


# lvm
#######
{% if salt['pillar.get']('storage:lvm', {}) %}

lvm2:
  pkg.installed

# lvm - pv
{% if salt['pillar.get']('storage:lvm:pv', {}) %}
{% for item in pillar.storage.lvm.pv %}
"lvm-pv-{{ item }}":
  lvm.pv_present:
    - name: {{ item }}
    - require:
      - pkg: lvm2
{% endfor %}
{% endif %}

# lvm - vg
{% if salt['pillar.get']('storage:lvm:vg', {}) %}
{% for item, data in pillar.storage.lvm.vg.iteritems() %}
"lvm-vg-{{ item }}":
  lvm.vg_present:
    - name: {{ item }}
    - devices: {% for device in salt['pillar.get']('storage:lvm:vg:'+ item+':devices') %}{{ device }}{% endfor %}
{% if salt['pillar.get']('storage:lvm:vg:'+ item+ ':options', {}) %}
{% for option, optvalue in salt['pillar.get']('storage:lvm:vg:'+ item+':options').iteritems() %}
    - {{ option }}{% if optvalue|d('') %}: {{ optvalue }}{% endif %}
{% endfor %}
{% endif %}
    - require:
      - pkg: lvm2
{% endfor %}
{% endif %}

# lvm - lv
{% if salt['pillar.get']('storage:lvm:lv', {}) %}
{% for item, data in pillar.storage.lvm.lv.iteritems() %}
"lvm-lv-{{ item }}":
  lvm.lv_present:
    - name: {{ item }}
{% for sub, subvalue in data.iteritems() %}
    - {{ sub }}{% if subvalue|d('') %}: {{ subvalue }}{% endif %}
{% endfor %}
    - require:
      - pkg: lvm2
{% endfor %}
{% endif %}

{% endif %}


# format
#######
{% if salt['pillar.get']('storage:format', {}) %}

{% for item, data in pillar.storage.format.iteritems() %}
{% set mkfs = 'mkswap' if data.fstype == 'swap' else 'mkfs.'+ data.fstype %}
{% set opts = data.opts if data.opts|d('') else "" %}
"format-{{ item }}":
  cmd.run:
    - name: '{{ mkfs }} {{ opts }} {{ item }}'
    - onlyif: 'test "$(blkid -p -s TYPE -o value {{ item }})" == ""'
    - unless: 'test "$(blkid -p -s TYPE -o value {{ item }})" == "{{ data.fstype }}"'
{% endfor %}

{% endif %}


# mount
#######
{% if salt['pillar.get']('storage:mount', {}) %}

{% for item, data in pillar.storage.mount.iteritems() %}
"mount-{{ item }}":
  mount.mounted:
    - name: {{ item }}
{% for sub, subvalue in data.iteritems() %}
    - {{ sub }}{% if subvalue|d('') %}: {{ subvalue }}{% endif %}
{% endfor %}
{% endfor %}

{% endif %}


# swap
#######
{% if salt['pillar.get']('storage:swap', {}) %}

{% for item in pillar.storage.swap %}
"swap-{{ item }}":
  mount.swap:
    - name: {{ item }}
{% endfor %}

{% endif %}

