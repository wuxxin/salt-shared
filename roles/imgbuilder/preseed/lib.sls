include:
  - .init

# preseed_make
###############

{% macro preseed_make(cs) %}

{% from "roles/imgbuilder/preseed/defaults.jinja" import defaults with context %}
{% set settings=salt['grains.filter_by']({'none': defaults },
  grain='none', default= 'none', merge= cs|d({})) %}

{% set tmp_target="/mnt/images/tmp/initrd-"+ cs.suite+ "-"+ cs.architecture %}
{% set netboot_target="/mnt/images/tmp/netboot-"+ cs.suite+ "-"+ cs.architecture %}

{{ initrd_unpack(cs, tmp_target, netboot_target) }}
{{ add_preseed_files(cs, tmp_target) }}
{{ initrd_pack(cs, tmp_target, netboot_target) }}

{% endmacro %}


{% macro initrd_unpack(cs, tmp_target, netboot_target) %}

{% set download_target="/mnt/images/tmp" %}

{% from "roles/imgbuilder/defaults.jinja" import settings as ib_s with context %}

netboot-dir:
  file.directory:
    - name: {{ netboot_target }}
    - makedirs: true
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}

get-netboot:
  file.managed:
    - name: "{{ download_target }}/netboot.tar.gz"
    - source: "{{ cs.source }}"
    - source_hash: {{ cs.source_hash }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - require:
      - file: netboot-dir
  cmd.run:
    - name: "tar xzf {{ download_target }}/netboot.tar.gz && chown -R {{ ib_s.user }}:{{ ib_s.user }} ."
    - cwd: {{ netboot_target }}
    - unless: test -f {{ netboot_target }}/ubuntu-installer/amd64/initrd.gz
    - require:
      - file: get-netboot
  
clean-initrd:
  file.absent:
    - name: {{ tmp_target }}

unpack-initrd:
  file.directory:
    - name: {{ tmp_target }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - makedirs: true
    - require:
      - file: clean-initrd
  cmd.run:
    - name:  cd {{ tmp_target }}; cat {{ netboot_target }}/{{ cs.initrd }} | gzip -d | cpio --extract --make-directories --no-absolute-filenames
    - require:
      - cmd: get-netboot

{% endmacro %}


{% macro add_preseed_files(cs, tmp_target) %}

{% from "roles/imgbuilder/defaults.jinja" import settings as ib_s with context %}

# generate preseed templates
{% for p in cs.preseed_list %}
{% for k,d in p.iteritems() %}
add-preseed-{{ k }}:
  file.append:
    - name: {{ tmp_target }}/{{ k }}
    - makedirs: true
    - sources:
{% for t in d %}
        - {{ cs.templates }}/{{ t }}
{% endfor %}
    - template: jinja
    - context:
        username: {{ cs.username|d(" ") }}
        hostname: {{ cs.hostname|d(" ") }}
        domainname: {{ cs.domainname|d(" ") }}
        password: {{ cs.password|d("''") }}
        diskpassword: {{ cs.diskpassword|d("''") }}
        netcfg: {{ cs.netcfg }}
        disks: {{ cs.disks|d("/dev/vda") }}
        apt_proxy_mirror: {{ cs.apt_proxy_mirror|d("''") }}

{% endfor %}
{% endfor %}

# symlink for default preseed
default-preseed:
  file.symlink:
    - name: {{ tmp_target }}/preseed.cfg
    - target: {{ cs.default_preseed }}

# file append to /debs/udeb-install.lst
{% if cs.additional_udeb %}
debs-udeb-install:
  file.append:
    - name: {{ tmp_target }}/custom/custom_udeb-install.lst
    - makedirs: true
    - text:
{% for u in cs.additional_udeb %}
      - {{ u }}
{% endfor %}
{% endif %}

# copy additional layers
{% if cs.additional_layers %}
{% set tmp_layers="/mnt/images/tmp/initrd-"+ cs.suite+ "-"+ cs.architecture+ "-layers" %}

{% for l in cs.additional_layers %}
"clean-tmpdir-{{ l }}":
  file.absent:
    - name: {{ tmp_layers }}

"mkdir-tmpdir-{{ l }}":
  file.directory:
    - name: {{ tmp_layers }}/
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - makedirs: true

"overlay-install-{{ l }}":
  file.managed:
    - source: {{ l }}
    - name: {{ tmp_layers }}/{{ salt['cmd.run']('basename '+ l) }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
  cmd.run:
    - name: tar xzf {{ tmp_layers }}/{{ salt['cmd.run']('basename '+ l) }} --overwrite --directory {{ tmp_target }}
{% endfor %}

"clean-tmpdir-done":
  file.absent:
    - name: {{ tmp_layers }}
{% endif %}

# add custom hook dir and scripts
add-hooks:
  file.recurse:
    - name: {{ tmp_target }}/custom
    - source: salt://roles/imgbuilder/preseed/hooks/
    - template: jinja
    - makedirs: true

# copy custom files to tmp target
{% if cs.custom_files %}
{% for d,s in cs.custom_files.iteritems()  %}
add-custom-files-{{ s }}:
  file.managed:
    - name: {{ tmp_target }}/{{ d }}
    - source: {{ s }}
    - makedirs: true
{% endfor %}
{% endif %}

# make /custom/custom.lst 
make-custom-list:
  file.managed:
    - name: {{ tmp_target }}/custom.lst
    - contents: |
{%- for n in salt['cmd.run']('cd '+ tmp_target+ '; ls custom/*').split() %}
{{ n|indent(8, true) }}
{%- endfor %}
{%- if cs.custom_files %}
{%- for d,s in cs.custom_files.iteritems() %}
{{ d|indent(8, true) }}
{%- endfor %}
{%- endif %}


{% endmacro %}


{% macro initrd_pack(cs, tmp_target, netboot_target) %}

{% from "roles/imgbuilder/defaults.jinja" import settings as ib_s with context %}

pack-initrd:
  file.directory:
    - name: {{ cs.target }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - makedirs: true
    - clean: true
  cmd.run:
    - name: cd {{ tmp_target }}; find . | cpio -H newc --create | gzip -9 > {{ cs.target }}/initrd.gz
    - require:
      - file: pack-initrd

copy-kernel:
  file.copy:
    - name: {{ cs.target }}/linux
    - source: {{ netboot_target}}/{{ cs.kernel }}
    - require:
      - cmd: pack-initrd

copy-password:
  file.managed:
    - name: {{ cs.target }}/{{ cs.username }}.passwd
    - contents: "{{ cs.password }}"
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - mode: 600

{% if cs.diskpassword_receiver_id == 'insecure_gpgkey' %}
{% set keyfiles = ("salt://roles/imgbuilder/preseed/files/insecure_gpgkey.secret.asc",
    "salt://roles/imgbuilder/preseed/files/insecure_gpgkey.key.asc") %}
{% else %}
{% set keyfiles = (cs.diskpassword_receiver_key, ) %}
{% endif %}

{% for f in keyfiles %}
preseed-lib-copy-{{ f }}:
  file.managed:
    - source: {{ f }}
    - name: {{ cs.target }}/{{ salt['cmd.run']('basename '+ f) }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - mode: 700
{% endfor %}

{% for f in ('Vagrantfile', 'load_kexec.sh', 'luksOpen.sh', 
'nw_console.sh', 'set_diskpassword.sh', 'connect_new.sh', 'make_paper_config.sh','data2qrpdf.sh') %}

preseed-lib-copy-{{ f }}:
  file.managed:
    - source: "salt://roles/imgbuilder/preseed/files/{{ f }}"
    - name: {{ cs.target }}/{{ f }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - mode: 700
    - template: jinja
    - context:
        target: {{ cs.target }}
        cmdline: {{ cs.cmdline }}
        custom_ssh_identity: {{ cs.custom_ssh_identity|d("") }}
        username: {{ cs.username|d(" ") }}
        hostname: {{ cs.hostname|d(" ") }}
        domainname: {{ cs.domainname|d(" ") }}
        netcfg: {{ cs.netcfg }}
        disks: {{ cs.disks|d("/dev/vda") }}
        apt_proxy_mirror: {{ cs.apt_proxy_mirror|d(" ") }}
        diskpassword_receiver_id: {{ cs.diskpassword_receiver_id|d("") }}
        diskpassword_receiver_key: {{ cs.diskpassword_receiver_key|d("") }}
        diskpassword_creation: {{ cs.diskpassword_creation|d("") }}
{% endfor %}

{% endmacro %}

