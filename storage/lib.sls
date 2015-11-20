# storage_setup
###############

{% macro storage_setup(data) %}

{% if data['parted'] is defined %}
{{ storage_parted(data.parted) }}
{% endif %}

{% if data['mdadm'] is defined %}
{{ storage_mdadm(data.mdadm) }}
{% endif %}

{% if data['crypt'] is defined %}
{{ storage_crypt(data.crypt) }}
{% endif %}

{% if data['lvm'] is defined %}
{{ storage_lvm(data.lvm) }}
{% endif %}

{% if data['format'] is defined %}
{{ storage_format(data.format) }}
{% endif %}

{% if data['mount'] is defined %}
{{ storage_mount(data.mount) }}
{% endif %}

{% if data['swap'] is defined %}
{{ storage_swap(data.swap) }}
{% endif %}

{% if data['directories'] is defined %}
{{ storage_directories(data.directories) }}
{% endif %}

{% if data['relocate'] is defined %}
{{ storage_relocate(data.relocate) }}
{% endif %}

{% endmacro %}


# parted
#######
{% macro storage_parted(input_data) %}

{% for item, data in input_data.iteritems() %}

{% set part_label = 'gpt' if data.label|d('') else data.label %}
{% set blkid_label = 'dos' if part_label == 'msdos' else part_label %}

"parted-{{ item }}":
  pkg.installed:
    - name: parted
  cmd.run:
    - name: parted --script {{ item }} mklabel {{ part_label }}
    - onlyif: 'test "$(blkid -p -s PTTYPE -o value {{ item }})" == ""'
    - unless: 'test "$(blkid -p -s PTTYPE -o value {{ item }})" == "{{ blkid_label }}"'
    - require:
      - pkg: "parted-{{ item }}"

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
    - unless: 'test -b {{ item }}{{ x }}'
    - require:
      - cmd: "parted-{{ item }}"

{% set x = x +1 %}

{% endfor %}
{% endif %}

{% endfor %}

{% endmacro %}


# mdadm
#######
{% macro storage_mdadm(input_data) %}

{% for item, data in input_data.iteritems() %}
"mdadm-raid-{{ item }}":
  pkg.installed:
    - name: mdadm
  raid.present:
    - name: {{ item }}
    - opts:
{%- for sub in data %}
      - {{ sub }}
{%- endfor %}
    - require:
      - pkg: "mdadm-raid-{{ item }}"

{% endfor %}

{% endmacro %}


# crypt
#######
{% macro storage_crypt(input_data) %}

{% for item, data in input_data.iteritems() %}

{{ item }}-luks-format:
  pkg.installed:
    - name: cryptsetup
  cmd.run:
    - unless: cryptsetup luksUUID {{ item }}
    - name: echo "{{ data['password'] }}" | cryptsetup luksFormat {{ item }}
    - require:
      - pkg: {{ item }}-luks-format

{{ item }}-luks-open:
  cmd.run:
    - unless: stat {{ data['target'] }}
    - name: echo "{{ data['password'] }}" | cryptsetup luksOpen {{ item }} {{ data['target'] }}
    - require:
      - cmd: {{ item }}-luks-format

{% endfor %}

{% endmacro %}


# lvm
#######
{% macro storage_lvm(input_data) %}

# lvm - pv
{% if input_data.pv is defined %}
{% for item in input_data.pv %}
"lvm-pv-{{ item }}":
  pkg.installed:
    - name: lvm2
  lvm.pv_present:
    - name: {{ item }}
    - require:
      - pkg: "lvm-pv-{{ item }}"
{% endfor %}
{% endif %}

# lvm - vg
{% if input_data.vg is defined %}
{% for item, data in input_data.vg.iteritems() %}
"lvm-vg-{{ item }}":
  pkg.installed:
    - name: lvm2
  lvm.vg_present:
    - name: {{ item }}
    - devices: {% for device in input_data.vg[item]['devices'] %}{{ device }}{% endfor %}
{%- if input_data.vg[item]['options']|d({}) %}
{%- for option, optvalue in input_data.vg[item]['options'].iteritems() %}
    - {{ option }}{% if optvalue|d('') %}: {{ optvalue }}{% endif %}
{%- endfor %}
{%- endif %}
    - require:
      - pkg: "lvm-vg-{{ item }}"
{% endfor %}
{% endif %}

# lvm - lv

{% if input_data.lv is defined %}
{% for item, data in input_data.lv.iteritems() %}
"lvm-lv-{{ item }}":
  pkg.installed:
    - name: lvm2

{%- set lvtarget='/dev/'+ data['vgname']+ '/' + item %}
{%- if "size" in data and "expand" in data and data['expand'] == True and
salt.lvm.lvdisplay(lvtarget)[lvtarget] is defined %}
{%- set req_size=salt['extutils.re_replace']('[ ]*([0-9\.]+)([^0-9\.]+)', '\\1', data['size']) %}
{%- set nomination=salt['extutils.re_replace']('[ ]*([0-9\.]+)([^0-9\.]+)', '\\2', data['size']) %}
{%- set current=salt['cmd.run']('lvdisplay -C --noheadings --units '+ nomination+ ' -o size '+ lvtarget) %}
{%- set curr_size=salt['extutils.re_replace']('[ ]*([0-9]+).*', '\\1', current) %}

{%- if req_size|int > curr_size|int %}
  cmd.run:
    - name: lvresize -L {{ data['size'] }} {{ lvtarget }}
    - require:
      - pkg: "lvm-lv-{{ item }}"

{%- if salt.cmd.run_stdout('blkid -p -s TYPE -o value '+ lvtarget) in (['ext2', 'ext3', 'ext4']) %}
"lvm-lv-{{ item }}-resize":
  cmd.run:
    - name: resize2fs {{ lvtarget }}
    - require:
      - cmd: "lvm-lv-{{ item }}"
{%- endif %}
{%- endif %}
"lvm-lv-test":
  cmd.run:
    - name: echo "{{ req_size }} , {{ curr_size }} {{ salt.cmd.run_stdout('blkid -p -s TYPE -o value '+ lvtarget) in (['ext2', 'ext3', 'ext4']) }}"

{%- else %}
  lvm.lv_present:
    - name: {{ item }}
{%- for sub, subvalue in data.iteritems() %}
{%- if sub not in ('watch_in', 'require_in', 'require', 'watch') %}
    - {{ sub }}{% if subvalue|d('') %}: {{ subvalue }}{% endif %}
{%- endif %}
{%- endfor %}
    - require:
      - pkg: "lvm-lv-{{ item }}"
{%- if 'require' in data %}
      - {{ data['require'] }}
{%- endif %}
{%- for sub, subvalue in data.iteritems() %}
{%- if sub in ('watch_in', 'require_in', 'watch') %}
    - {{ sub }}:
      - {{ subvalue }}
{%- endif %}
{%- endfor %}

{% endif %}

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
{%- for a in ('watch_in', 'require_in', 'require', 'watch') %}
{%- if input_data[item][a] is defined %}
    - {{ a }}:
      - {{ input_data[item][a] }}
{%- endif %}
{%- endfor %}

{% endfor %}

{% endmacro %}


# mount
#######
{% macro storage_mount(input_data) %}

{% for item, data in input_data.iteritems() %}
"mount-{{ item }}":
  mount.mounted:
    - name: {{ item }}
{%- for sub, subvalue in data.iteritems() %}
    - {{ sub }}{% if subvalue|d('') %}: {{ subvalue }}{% endif %}
{%- endfor %}
    - onlyif: 'test "$(blkid -p -s TYPE -o value {{ data['device'] }})" == "{{ data['fstype'] }}"'
    - unless: 'test ! -b {{ data['device'] }}'
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

{% if input_data[item]['names']|d({}) %}
{% for child in input_data[item]['names'] %}

"{{ item }}/{{ child }}-mkdir":
 file.directory:
    - name: {{ item }}/{{ child }}
    - makedirs: True
{%- if input_data[item]['options']|d({}) %}
{%- for option in input_data[item]['options'] %}
    - {{ option }}
{%- endfor %}
{%- endif %}

{%- for a in ('onlyif', 'unless') %}
{%- if input_data[item][a] is defined %}
    - {{ a }}: {{ input_data[item][a] }}
{%- endif %}
{%- endfor %}

{%- for a in ('watch_in', 'require_in', 'require', 'watch') %}
{%- if input_data[item][a] is defined %}
    - {{ a }}:
      - {{ input_data[item][a] }}
{%- endif %}
{%- endfor %}

{%- endfor %}
{%- endif %}

{% endfor %}

{% endmacro %}



# relocate
##########

{% macro storage_relocate(input_data) %}

{% for item, data in input_data.iteritems() %}

{{ item }}-{{ data['destination'] }}-relocate:
  cmd.run:
{%- if data['copy_content']|d(true) %}
    - name: x={{ item }}; y=`basename $x`; if test -d $x; then cp -a -t {{ data['destination'] }} $x && rm -r $x; fi; ln -s -T {{ data['destination'] }}/$y {{ item }}
{%- else %}
    - name: rm -r {{ item }}; ln -s -T {{ data['destination'] }}/`basename {{ item }}` {{ item }}
{%- endif %}
    - unless: test -L {{ item }}
    - onlyif: test -d {{ data['destination'] }}

{%- for a in ('watch_in', 'require_in', 'require', 'watch') %}
{%- if input_data[item][a] is defined %}
    - {{ a }}:
      - {{ input_data[item][a] }}
{%- endif %}
{%- endfor %}

{% endfor %}

{% endmacro %}
