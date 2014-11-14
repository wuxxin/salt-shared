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

get-netboot:
  archive.extracted:
    - name: {{ netboot_target }}/
    - source: {{ cs.source }}
    - source_hash: {{ cs.source_hash }}
    - user: imgbuilder
    - group: imgbuilder
    - archive_format: tar
    - tar_options: z
    - if_missing: {{ netboot_target }}/

clean-initrd:
  file.absent:
    - name: {{ tmp_target }}

unpack-initrd:
  file.directory:
    - name: {{ tmp_target }}
    - user: imgbuilder
    - group: imgbuilder
    - makedirs: true
    - require:
      - file: clean-initrd
  cmd.run:
    - name:  cd {{ tmp_target }}; cat {{ netboot_target }}/{{ cs.initrd }} | gzip -d | cpio --extract --make-directories --no-absolute-filenames
    - require:
      - archive: get-netboot

{% endmacro %}


{% macro add_preseed_files(cs, tmp_target) %}

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
        password: {{ cs.password|d(" ") }}
        diskpassword: {{ cs.diskpassword|d(" ") }}
        netcfg: {{ cs.netcfg }}
        disks: {{ cs.disks|d("/dev/vda") }}
        apt_proxy_mirror: {{ cs.apt_proxy_mirror|d(" ") }}

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
    - user: imgbuilder
    - group: imgbuilder
    - makedirs: true

"overlay-install-{{ l }}":
  file.managed:
    - source: {{ l }}
    - name: {{ tmp_layers }}/{{ salt['cmd.run']('basename '+ l) }}
    - user: imgbuilder
    - group: imgbuilder
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
{% for (d,s) in cs.custom_files  %}
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
    name: {{ tmp_target }}/custom.lst
    contents: |
{% for n in salt['cmd.run_stdout']('cd '+ tmp_target+ '; ls custom/*') %}
{{ n|indent(8, true) }}
{%- endfor %}
{%- if cs.custom_files %}
{%- for (d,s) in cs.custom_files  %}
{{ d|indent(8, true) }}
{%- endfor %}
{%- endif %}


{% endmacro %}


{% macro initrd_pack(cs, tmp_target, netboot_target) %}

pack-initrd:
  file.directory:
    - name: {{ cs.target }}
    - user: imgbuilder
    - group: imgbuilder
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
    - user: imgbuilder
    - group: imgbuilder
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
    - user: imgbuilder
    - group: imgbuilder
    - mode: 700
{% endfor %}

{% for f in ('Vagrantfile', 'load_kexec.sh', 'luksOpen.sh', 
'nw_console.sh', 'set_diskpassword.sh', 'connect_new.sh', 'make_paper_config.sh','data2qrpdf.sh') %}

preseed-lib-copy-{{ f }}:
  file.managed:
    - source: "salt://roles/imgbuilder/preseed/files/{{ f }}"
    - name: {{ cs.target }}/{{ f }}
    - user: imgbuilder
    - group: imgbuilder
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

