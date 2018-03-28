# storage_setup
###############

{% macro storage_setup(data) %}
{%- if data['parted'] is defined %}
{{ storage_parted(data.parted) }}
{%- endif %}
{%- if data['mdadm'] is defined %}
{{ storage_mdadm(data.mdadm) }}
{%- endif %}
{%- if data['crypt'] is defined %}
{{ storage_crypt(data.crypt) }}
{%- endif %}
{%- if data['lvm'] is defined %}
  {%- if data['lvm']['pv'] is defined %}
{{ storage_lvm_pv(data.lvm.pv) }}
  {%- endif %}
  {%- if data['lvm']['vg'] is defined %}
{{ storage_lvm_vg(data.lvm.vg) }}
  {%- endif %}
  {%- if data['lvm']['lv'] is defined %}
{{ storage_lvm_lv(data.lvm.lv) }}
  {%- endif %}
{%- endif %}
{%- if data['format'] is defined %}
{{ storage_format(data.format) }}
{%- endif %}
{%- if data['mount'] is defined %}
{{ storage_mount(data.mount) }}
{%- endif %}
{%- if data['swap'] is defined %}
{{ storage_swap(data.swap) }}
{%- endif %}
{%- if data['directory'] is defined %}
{{ storage_directory(data.directory) }}
{%- endif %}
{%- if data['relocate'] is defined %}
{{ storage_relocate(data.relocate) }}
{%- endif %}
{% endmacro %}


# parted
#######
{% macro storage_parted(input_data) %}

{# 
# example: use whole disk for root partition
parted:
  - device: /dev/vda
    type: mbr # can be mpr or gpt
    parts:
      - name root
        start: 1024kiB
        end: "100%"
        flags:
          - boot
          # flag list will be translated into parted flags
#}

  {% for data in input_data %}
    {% set part_type = 'msdos' if data.type|d('') == 'mbr' else data.type|d('') %}
    {% set blkid_type = 'dos' if part_type == 'msdos' else part_type %}

"parted-{{ data.device }}":
  pkg.installed:
    - name: parted

    {% if part_type != '' %}
  cmd.run:
    - name: parted --script {{ data.device }} mklabel {{ part_type }}
    - onlyif: 'test "$(blkid -p -s PTTYPE -o value {{ data.device }})" == ""'
    - require:
      - pkg: "parted-{{ data.device }}"
      {%- if data.parts|d('') %}
        {%- set x=1 %}
    - require_in:
        {%- for part in data.parts|d([]) %}
      - cmd: "parted-{{ data.device }}-{{ x }}-{{ part.name }}"
          {%- set x = x +1 %}
        {%- endfor %}
      {%- endif %}
    {% endif %}

    {% if data.parts|d('') %}
      {% set x=1 %}

      {% for part in data.parts %}
        {% set flags= [] %}
        {% if part.flags is defined %}
          {% for flagname in part.flags %}
            {% do flags.append("set "~ x~ " "~ flagname~ " on") %}
          {% endfor %}
        {% endif %}

"parted-{{ data.device }}-{{ x }}-{{ part.name }}":
  cmd.run:
    - name: parted --align optimal --script {{ data.device }} mkpart {{ part.name }} {{ part.start }} {{ part.end }} {{ flags|join(' ') }}
    - unless: 'test -b {{ data.device }}{{ x }}'
    - require:
      - cmd: "parted-{{ data.device }}"

        {% set x = x +1 %}
      {% endfor %}
    {% endif %}
  {% endfor %}

{% endmacro %}


# mdadm
#######
{% macro storage_mdadm(input_data) %}

{# 
# example: make two raid1 devices md0=vdb2,vdc2, md1=vdb4,vdc4
mdadm:
  {% for a,b in [(0, 2), (1, 4)] %}
  - target: /dev/md{{ a }}"
    level: 1
    devices:
      - /dev/vdb{{ b }}
      - /dev/vdc{{ b }}
    # optional kwargs passed to mdadm.raid_present
  {% endfor %}
#}

  {% for data in input_data %}
"mdadm-raid-{{ data.target }}":
  pkg.installed:
    - name: mdadm
  raid.present:
    - name: {{ data.target }}
    - level: {{ data['level'] }}
    - devices:
    {%- for device in data['devices'] %}
      - {{ device }}
    {%- endfor %}
    {%- for opt, optvalue in data.iteritems() %}
      {%- if opt not in ['target', 'level', 'devices', 'require'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
    - require:
      - pkg: "mdadm-raid-{{ data.target }}"
{{ (data['require']|yaml(False))|indent(6, True) if data['require'] is defined else '' }}
  {% endfor %}

{% endmacro %}


# crypt
#######
{% macro storage_crypt(input_data) %}

{#
# example: crypt device /dev/md1 and make it available under /dev/cryptlvm
crypt:
  - device: /dev/md1
    name: "cryptlvm"
    password: "my-useless-password"
    # optional kwargs for cmd.run:cryptsetup luksFormat, cmr.run:cryptsetup open
#}

  {% for data in input_data %}
{{ data.device }}-luks-format:
  pkg.installed:
    - name: cryptsetup
  cmd.run:
    - unless: cryptsetup luksUUID {{ data.device }}
    - name: echo "{{ data['password'] }}" | cryptsetup luksFormat {{ data.device }}
    {%- for opt, optvalue in data.iteritems() %}
      {%- if opt not in ['device', 'name', 'password', 'require'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
    - require:
      - pkg: {{ data.device }}-luks-format
{{ (data['require']|yaml(False))|indent(6, True) if data['require'] is defined else '' }}

{{ data.device }}-luks-open:
  cmd.run:
    - unless: stat /dev/mapper/{{ data['name'] }}
    - name: echo "{{ data['password'] }}" | cryptsetup open --type luks {{ data.device }} {{ data['name'] }}
    {%- for opt, optvalue in data.iteritems() %}
      {%- if opt not in ['device', 'name', 'password', 'require'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
    - require:
      - cmd: {{ data.device }}-luks-format
{{ (data['require']|yaml(False))|indent(6, True) if data['require'] is defined else '' }}
  {% endfor %}

{% endmacro %}


# lvm:pv
#######
{% macro storage_lvm_pv(input_data) %}

{# 
# example: format a device as physical lvm volume
lvm:
  pv:
    devices: 
      - /dev/vdb1
    # optional kwargs for lvm.pv_present
#}
  {% set data= input_data %}
  {% for item in data['devices'] %}
"lvm-pv-{{ item }}":
  pkg.installed:
    - name: lvm2
  lvm.pv_present:
    - name: {{ item }}
    {%- for opt, optvalue in data.iteritems() %}
      {%- if opt not in ['devices', 'require'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
    - require:
      - pkg: "lvm-pv-{{ item }}"
{{ (data['require']|yaml(False))|indent(6, True) if data['require'] is defined else '' }}
  {%- endfor %}
    
{% endmacro %}


# lvm:vg
#######
{% macro storage_lvm_vg(input_data) %}

{# 
# example: use device vdb1 (which is formated as lvm:pg volume) as volume group
lvm:
  vg:
    - name: vg0
      devices:
        - /dev/vdb1
      # optional kwargs passed to lvm.vg_present
#}

  {% for data in input_data %}
"lvm-vg-{{ data.name }}":
  pkg.installed:
    - name: lvm2
  lvm.vg_present:
    - name: {{ data.name }}
    - devices:
    {%- for device in data['devices'] %}
      - {{ device }}
    {%- endfor %}
    {%- for opt, optvalue in data.iteritems() %}
      {%- if opt not in ['name', 'devices', 'require'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
    - require:
      - pkg: "lvm-vg-{{ data.name }}"
{{ (data['require']|yaml(False))|indent(6, True) if data['require'] is defined else '' }}
  {% endfor %}

{% endmacro %}


# lvm:lv
#######
{% macro storage_lvm_lv(input_data) %}

{# example: create logical volume host_root on volume group vg0 with 100g size
lvm:
  lv:
    - name: host_root
      vgname: vg0
      size: 100g
      # optional kwargs passed to lvm.lv_present
    - name: other_volume
      size: 50g
      expand: true
      # no optional kwargs are passed, volume must exist, volume is resized
#}

  {% for data in input_data %}
"lvm-lv-{{ data.name }}":
  pkg.installed:
    - name: lvm2

    {%- set lvtarget='/dev/'+ data['vgname']+ '/' + data.name %}
    {%- if "size" in data and "expand" in data and data['expand'] == True and
    salt.lvm.lvdisplay(lvtarget)[lvtarget] is defined %}
{{ expand_lv(data.name, lvtarget, size) }}
    {%- else %}
    
  lvm.lv_present:
    - name: {{ data.name }}
      {%- for opt, optvalue in data.iteritems() %}
        {%- if opt not in ['name', 'require'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
        {%- endif %}
      {%- endfor %}
    - require:
      - pkg: "lvm-lv-{{ data.name }}"
{{ (data['require']|yaml(False))|indent(6, True) if data['require'] is defined else '' }}
    {%- endif %}
  {% endfor %}

{% endmacro %}


# expand_lv
#######
{% macro expand_lv(item, lvtarget, size) %}

  {%- set req_size=salt['extutils.re_replace']('[ ]*([0-9\.]+)([^0-9\.]+)', '\\1', size) %}
  {%- set nomination=salt['extutils.re_replace']('[ ]*([0-9\.]+)([^0-9\.]+)', '\\2', size) %}
  {%- set current=salt['cmd.run']('lvdisplay -C --noheadings --units '+ nomination+ ' -o size '+ lvtarget) %}
  {%- set curr_size=salt['extutils.re_replace']('[ ]*([0-9]+).*', '\\1', current) %}

  {%- if req_size|int > curr_size|int %}
"lvm-lv-expand-{{ item }}":
  cmd.run:
    - name: lvresize -L {{ size }} {{ lvtarget }}
    - require:
      - pkg: "lvm-lv-{{ item }}"

    {%- if salt.cmd.run_stdout('blkid -p -s TYPE -o value '+ lvtarget) in (['ext2', 'ext3', 'ext4']) %}
"lvm-lv-resize-{{ item }}":
  cmd.run:
    - name: resize2fs {{ lvtarget }}
    - require:
      - cmd: "lvm-lv-{{ item }}"
    {%- endif %}
  {%- endif %}
  
"lvm-lv-expand-result-{{ item }}":
  cmd.run:
    - name: echo "{{ req_size }} , {{ curr_size }} {{ salt.cmd.run_stdout('blkid -p -s TYPE -o value '+ lvtarget) in (['ext2', 'ext3', 'ext4']) }}"

{% endmacro %}


# format
#######

{% macro storage_format(input_data) %}

{# 
format:
  - device: /dev/mapper/vg0-host_root
    fstype: ext4
    options: # passed to mkfs
      - "-L my_root"
    # optional kwargs passed to cmd.run:mkfs
#}
  {% for data in input_data() %}
    {%- set fstype = data.fstype|d('ext4') %}
    {%- set mkfs = 'mkswap' if fstype == 'swap' else 'mkfs.'+ fstype %}
    {%- set options = data.options|d([]) %}
"format-{{ data.device }}":
  cmd.run:
    - name: '{{ mkfs }} {%- for option in options %}{{ option }} {%- endfor %} {{ data.device }}'
    - onlyif: 'test "$(blkid -p -s TYPE -o value {{ data.device }})" == ""'
    {%- for opt, optvalue in data.iteritems() %}
      {%- if opt not in ['device', 'fstype', 'options'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
  {% endfor %}

{% endmacro %}


# mount
#######

{% macro storage_mount(input_data) %}
{# 
mount:
  - device: /dev/mapper/vg0-images
    target: /mnt/images
    # optional kwargs for mount.mounted
    # defaults:
    #  fstype: ext4
    #  mkmnt: true 
#}
  {% for data in input_data() %}
     {%- set fstype= data.fstype|d('ext4') %}
mount-{{ data.target }}:
  mount.mounted:
    - name: {{ data.target }}
    - device: {{ data.device }}
    - mkmnt: {{ data.mkmnt|d(true) }}
    - fstype: {{ fstype }}
    - onlyif: test -b {{ data.device }} -a "$(blkid -p -s TYPE -o value {{ data.device }})" == "{{ fstype }}"
    {%- for opt, optvalue in data.iteritems() %}
      {%- if opt not in ['path', 'device', 'mkmnt', 'fstype'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
  {% endfor %}

{% endmacro %}


# swap
#######
{% macro storage_swap(input_data) %}

{#
swap:
  - /dev/mapper/vg0-host_swap
#}
  {% for item in input_data %}
"swap-{{ item }}":
  mount.swap:
    - name: {{ item }}
  {% endfor %}

{% endmacro %}


# directory
#######
{% macro storage_directory(input_data) %}

{# 
# example: make a directory structure under mountpoint /volatile
directory:
  - name: /volatile
    mountpoint: true  # defaults to false
    # optional kwargs for file.directory
    # defaults are makedirs:true
  - name: /volatile/docker
  - name: /volatile/alertmanager
    # optional kwargs for file.directory
    # defaults are makedirs:true
    user: 1000
    group: 1000
    dir_mode: 755
    file_mode: 644
#}

  {% for data in input_data %}
"base_directory_{{ data.name }}":
  file.directory:
    - makedirs: {{ data['makedirs']|d(true) }}
    {%- if data['mountpoint']|d(false) %}
    - onlyif: mountpoint -q {{ data.name }}
    {%- endif %}
    {%- for opt, optvalue in data.iteritems() %}
      {%- if opt not in ['mountpoint', 'makedirs', 'parts'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
  {%- endfor %}
    
{% endmacro %}


{% macro storage_relocate(input_data) %}

{# 
# example: relocate docker and other directory
relocate:
  - source: /var/lib/docker
    target: /volatile/docker
    prefix: docker kill $(docker ps -q); systemctl stop docker
    postfix: systemctl start docker
    # optional kwargs for cmd.run:prefix, file.rename, file.symlink, cmd.run:postfix
  - source: /app/.cache/duplicity
    target: /volatile/duplicity
#}
  {% for item in input_data %}
    {%- set source= item.source %}
    {%- set target= item.target %}
    {%- set prefix= item.prefix|d("true") %}
    {%- set postfix= item.postfix|d("true") %}

"pre_rel_{{ source }}":
  cmd.run:
    - name: "{{ prefix }}"
    - onlyif: test -d {{ target }} -a -e {{ source }} -a ! -L {{ source }}
    {%- for opt, optvalue in item.iteritems() %}
      {%- if opt not in ['source', 'target', 'prefix', 'postfix'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}

"relocate_{{ source }}":
  file.rename:
    - name: {{ target }}
    - source: {{ source }}
    - force: true
    - onlyif: test -d {{ target }} -a -e {{ source }} -a ! -L {{ source }}
    {%- for opt, optvalue in item.iteritems() %}
      {%- if opt not in ['source', 'target', 'prefix', 'postfix', 'require'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
    - require:
      - cmd: "pre_rel_{{ source }}"
{{ (item['require']|yaml(False))|indent(6, True) if item['require'] is defined else '' }}

"symlink_{{ source }}":
  file.symlink:
    - name: {{ source }}
    - target: {{ target }}
    - onlyif: test -d {{ target }} -a ! -L {{ source }}
    {%- for opt, optvalue in item.iteritems() %}
      {%- if opt not in ['source', 'target', 'prefix', 'postfix', 'require'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
    - require:
      - file: "relocate_{{ source }}"
{{ (item['require']|yaml(False))|indent(6, True) if item['require'] is defined else '' }}

"post_rel_{{ source }}":
  cmd.run:
    - name: "{{ postfix }}"
    - onchanges:
      - file: "relocate_{{ source }}"
    {%- for opt, optvalue in item.iteritems() %}
      {%- if opt not in ['source', 'target', 'prefix', 'postfix'] %}
    {{ ("- "+ {opt: optvalue}|yaml(False))|indent(6, False) }}
      {%- endif %}
    {%- endfor %}
  {% endfor %}
{% endmacro %}
