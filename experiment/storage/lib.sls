
# storage_setup
###############

{% macro storage_setup(data) %}

{% if data.parted %}
{{ storage_parted(data.parted) }}
{% endif %}

{% if data.mdadm %}
{{ storage_mdadm(data.mdadm) }}
{% endif %}

{% if data.lvm %}
{{ storage_lvm(data.lvm) }}
{% endif %}

{% if data.format %}
{{ storage_format(data.format) }}
{% endif %}

{% if data.mount %}
{{ storage_mount(data.mount) }}
{% endif %}

{% if data.swap %}
{{ storage_swap(data.swap) }}
{% endif %}

{% if data.directories %}
{{ storage_directories(data.directories) }}
{% endif %}

{% if data.relocate %}
{{ storage_relocate(data.relocate) }}
{% endif %}

{% endmacro %}


# parted
#######
{% macro storage_parted(input_data) %}

parted:
  pkg.installed

{% for item, data in input_data.iteritems() %}

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
{% set x=1 %}

{% for part in data.parts %}

{% set flags= [] %}
{% if part.flags is defined %}
{% for flagname in part.flags %}
{% do flags.append("set "~ x~ " "~ flagname~ " on") %}
{% endfor %}
{% endif %}

"parted-{{ item }}-{{ x }}-{{ part.name }}":
  cmd.run:
    - name: parted --align optimal --script {{ item }} mkpart {{ part.name }} {{ part.start }} {{ part.end }} {{ flags|join(' ') }}
    - unless: 'test -b {{ item }}{{ x }})"'
    - require:
      - pkg: parted
      - cmd: "parted-{{ item }}"

{% set x = x +1 %}

{% endfor %}
{% endif %}

{% endfor %}

{% endmacro %}


# mdadm
#######
{% macro storage_mdadm(input_data) %}

mdadm:
  pkg.installed

{% for item, data in input_data.iteritems() %}
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

{% endmacro %}


# lvm
#######
{% macro storage_lvm(input_data) %}

lvm2:
  pkg.installed

# lvm - pv
{% if input_data.pv %}
{% for item in input_data.pv %}
"lvm-pv-{{ item }}":
  lvm.pv_present:
    - name: {{ item }}
    - require:
      - pkg: lvm2
{% endfor %}
{% endif %}

# lvm - vg
{% if input_data.vg %}
{% for item, data in input_data.vg.iteritems() %}
"lvm-vg-{{ item }}":
  lvm.vg_present:
    - name: {{ item }}
    - devices: {% for device in input_data.vg[item]['devices'] %}{{ device }}{% endfor %}
{% if input_data.vg[item]['options']|d({}) %}
{% for option, optvalue in input_data.vg[item]['options'].iteritems() %}
    - {{ option }}{% if optvalue|d('') %}: {{ optvalue }}{% endif %}
{% endfor %}
{% endif %}
    - require:
      - pkg: lvm2
{% endfor %}
{% endif %}

# lvm - lv

{% if input_data.lv %}
{% for item, data in input_data.lv.iteritems() %}
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

{% endmacro %}


# format
#######
{% macro storage_format(input_data) %}

{% for item, data in input_data.iteritems() %}
{% set mkfs = 'mkswap' if data.fstype == 'swap' else 'mkfs.'+ data.fstype %}
{% set opts = data.opts if data.opts|d('') else "" %}
"format-{{ item }}":
  cmd.run:
    - name: '{{ mkfs }} {{ opts }} {{ item }}'
    - onlyif: 'test "$(blkid -p -s TYPE -o value {{ item }})" == ""'
    - unless: 'test "$(blkid -p -s TYPE -o value {{ item }})" == "{{ data.fstype }}"'
{% endfor %}

{% endmacro %}


# mount
#######
{% macro storage_mount(input_data) %}

{% for item, data in input_data.iteritems() %}
"mount-{{ item }}":
  mount.mounted:
    - name: {{ item }}
{% for sub, subvalue in data.iteritems() %}
    - {{ sub }}{% if subvalue|d('') %}: {{ subvalue }}{% endif %}
{% endfor %}
{% endfor %}

{% endmacro %}


# swap
#######
{% macro storage_swap(input_data) %}

{% for item in input_data %}
"swap-{{ item }}":
  mount.swap:
    - name: {{ item }}
{% endfor %}

{% endmacro %}


# directories
#######
{% macro storage_directories(input_data) %}

{% for item, data in input_data.iteritems() %}

{% if input_data[item]['childs']|d({}) %}
{% for child in input_data[item]['childs'] %}

{{ item }}/{{ child }}-mkdir:
 file.directory:
    - name: {{ item }}
{% if input_data[item]['options']|d({}) %}
{% for option, optvalue in input_data[item]['options'].iteritems() %}
    - {{ option }}{% if optvalue|d('') %}: {{ optvalue }}{% endif %}
{% endfor %}
{% endif %}

{% for a in ('onlyif', 'unless') %}
{% if input_data[item][a] %}
    - {{ a }}: input_data[item][a]
{% endif %}
{% endfor %}

{% for a in ('watch_in', 'require_in', 'require', 'watch') %}
{% if input_data[item][a] %}
    - {{ a }}:
      input_data[item][a]
{% endif %}
{% endfor %}

{% endfor %}
{% endif %}

{% endfor %}

{% endmacro %}



# relocate
##########

{% macro storage_relocate(input_data) %}

{% for item, data in input_data.iteritems() %}

{{ item }}-relocate:
  cmd.run:
{% if data['copy_content']|d(true) %}
    - name: x={{ item }}; if test -d $x; then cp -r $x/* {{ data['destination'] }}; rm -r $x; fi; ln -s -T {{ data['destination'] }} {{ item }}
{% else %}
    - name: rm -r {{ item }}; ln -s -T {{ data['destination'] }} {{ item }}
{% endif %}
    - unless: test -L {{ item }}
    - onlyif: test -d {{ data['destination'] }}

{% for a in ('watch_in', 'require_in', 'require', 'watch') %}
{% if input_data[item][a] %}
    - {{ a }}:
      - input_data[item][a]
{% endif %}
{% endfor %}

{% endfor %}

{% endmacro %}
