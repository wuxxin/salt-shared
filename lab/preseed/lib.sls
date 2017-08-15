include:
  - .init

# preseed_make
###############
{% macro netboot_source(baseurl, suite, suite_extension, architecture, flavor, version) %}
netboot_source: {{ baseurl }}{{ suite }}{{ suite_extension }}/main/installer-{{ architecture }}/{{ version }}/images/{{ flavor }}/{{ architecture }}
{% endmacro %}

{% macro netboot_cmdline(hostname) %}
cmdline: 'DEBCONF_DEBUG=1 ro hostname={{ hostname }} fb=false auto=true priority=critical debconf/frontend=noninteractive'
{% endmacro %}

{% macro preseed_make(cs) %}

{% from "preseed/defaults.jinja" import defaults with context %}
{% set settings=salt['grains.filter_by']({'none': defaults },
  grain='none', default= 'none', merge= cs|d({})) %}

{% set netboot_target="/mnt/images/tmp/netboot-"+ cs.suite+ "-"+ cs.architecture %}

"netboot-dir-{{ tmp_target }}":
  file.directory:
    - name: {{ netboot_target }}
    - makedirs: true
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}

{{ get_kernel(cs, tmp_target, netboot_target) }}
{{ get_initrd(cs, tmp_target, netboot_target) }}
{{ initrd_unpack(cs, tmp_target, netboot_target) }}
{{ add_preseed_files(cs, tmp_target) }}
{{ initrd_pack(cs, tmp_target, netboot_target) }}

{% endmacro %}


{% macro get_kernel(cs, netboot_target) %}

get-kernel-{{ tmp_target }}:
  file.managed:
    - name: "{{ netboot_target }}/linux"
    - source: "{{ cs.source }}"

{% macro initrd_unpack(cs, tmp_target, netboot_target) %}

{% set download_target="/mnt/images/tmp" %}

{% from "defaults.jinja" import settings as ib_s with context %}

    
"get-netboot-{{ tmp_target }}":
  file.managed:
    - name: "{{ download_target }}/netboot.tar.gz"
    - source: "{{ cs.source }}"
    - source_hash: {{ cs.source_hash }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - require:
      - file: "netboot-dir-{{ tmp_target }}"
  cmd.run:
    - name: "tar xzf {{ download_target }}/netboot.tar.gz && chown -R {{ ib_s.user }}:{{ ib_s.user }} ."
    - cwd: {{ netboot_target }}
    - unless: test -f {{ netboot_target }}/ubuntu-installer/amd64/initrd.gz
    - require:
      - file: "get-netboot-{{ tmp_target }}"

"clean-initrd-{{ tmp_target }}":
  file.absent:
    - name: {{ tmp_target }}

"unpack-initrd-{{ tmp_target }}":
  file.directory:
    - name: {{ tmp_target }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - makedirs: true
    - require:
      - file: "clean-initrd-{{ tmp_target }}"
  cmd.run:
    - name:  cd {{ tmp_target }}; cat {{ netboot_target }}/{{ cs.initrd }} | gzip -d | cpio --extract --make-directories --no-absolute-filenames
    - require:
      - cmd: "get-netboot-{{ tmp_target }}"

{% endmacro %}


{% macro add_preseed_files(cs, tmp_target) %}

{% from "defaults.jinja" import settings as ib_s with context %}

# generate preseed templates
{% for p in cs.preseed_list %}
{% for k,d in p.iteritems() %}
"add-preseed-{{ k }}-{{ tmp_target }}":
  file.append:
    - name: {{ tmp_target }}/{{ k }}
    - makedirs: true
    - sources:
{%- for t in d %}
        - {{ cs.templates }}/{{ t }}
{%- endfor %}
    - template: jinja
    - context:
        username: {{ cs.username|d("''") }}
        hostname: {{ cs.hostname|d("''") }}
        domainname: {{ cs.domainname|d("''") }}
        password: {{ cs.password|d("''") }}
        diskpassword: {{ cs.diskpassword|d("''") }}
        netcfg: {{ cs.netcfg }}
        disks: {{ cs.disks|d("/dev/vda") }}
        apt_proxy_mirror: {{ cs.apt_proxy_mirror|d("''") }}
        kernel_image: {{ cs.kernel_image|d("''") }}

{% endfor %}
{% endfor %}

# symlink for default preseed
"default-preseed-{{ tmp_target }}":
  file.symlink:
    - name: {{ tmp_target }}/preseed.cfg
    - target: {{ cs.default_preseed }}

# file append to /debs/udeb-install.lst
{% if cs.additional_udeb %}
"debs-udeb-install-{{ tmp_target }}":
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
"clean-tmpdir-{{ l }}-{{ tmp_target }}":
  file.absent:
    - name: {{ tmp_layers }}

"mkdir-tmpdir-{{ l }}-{{ tmp_target }}":
  file.directory:
    - name: {{ tmp_layers }}/
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - makedirs: true

"overlay-install-{{ l }}-{{ tmp_target }}":
  file.managed:
    - source: {{ l }}
    - name: {{ tmp_layers }}/{{ salt['cmd.run']('basename '+ l) }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
  cmd.run:
    - name: tar xzf {{ tmp_layers }}/{{ salt['cmd.run']('basename '+ l) }} --overwrite --directory {{ tmp_target }}
{% endfor %}

"clean-tmpdir-done-{{ tmp_target }}":
  file.absent:
    - name: {{ tmp_layers }}
{% endif %}

# add custom hook dir and scripts
"add-hooks-{{ tmp_target }}":
  file.recurse:
    - name: {{ tmp_target }}/custom
    - source: salt://preseed/hooks/
    - template: jinja
    - makedirs: true

# copy custom files to tmp target
{% if cs.custom_files %}
{% for d,s in cs.custom_files.iteritems()  %}
"add-custom-files-{{ s }}-{{ tmp_target }}":
  file.copy:
    - name: {{ tmp_target }}/{{ d }}
    - source: {{ s }}
    - makedirs: true
{% endfor %}
{% endif %}

# make /custom/custom.lst
"create.custom-list-{{ tmp_target }}":
  file.touch:
    - name: {{ tmp_target }}/custom.lst
    - makedirs: true

"make-custom-list-{{ tmp_target }}":
  cmd.run:
    - name: if test -d custom; then find custom -type f > {{ tmp_target }}/custom.lst; fi
    - cwd: {{ tmp_target }}
    - require:
      - file: "create.custom-list-{{ tmp_target }}"
{%- if cs.custom_files %}
  file.append:
    - name: {{ tmp_target }}/custom.lst
    - text: |
{%- for d,s in cs.custom_files.iteritems() %}
{{ d|indent(8, true) }}
{%- endfor %}
    - require:
      - cmd: "make-custom-list-{{ tmp_target }}"
{%- endif %}


{% endmacro %}


{% macro initrd_pack(cs, tmp_target, netboot_target) %}

{% from "defaults.jinja" import settings as ib_s with context %}

"pack-initrd-{{ tmp_target }}":
  file.directory:
    - name: {{ cs.target }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - makedirs: true
    - clean: true
  cmd.run:
    - name: cd {{ tmp_target }}; find . | cpio -H newc --create | gzip -9 > {{ cs.target }}/initrd.gz
    - require:
      - file: "pack-initrd-{{ tmp_target }}"

"copy-kernel-{{ tmp_target }}":
  file.copy:
    - name: {{ cs.target }}/linux
    - source: {{ netboot_target}}/{{ cs.kernel }}
    - require:
      - cmd: "pack-initrd-{{ tmp_target }}"

"copy-password-{{ tmp_target }}":
  file.managed:
    - name: {{ cs.target }}/{{ cs.username }}.passwd
    - contents: "{{ cs.password }}"
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - mode: 600

{% if cs.diskpassword_receiver_id == 'insecure_gpgkey' %}
{% set keyfiles = ("salt://preseed/files/insecure_gpgkey.secret.asc",
    "salt://preseed/files/insecure_gpgkey.key.asc") %}
{% else %}
{% set keyfiles = (cs.diskpassword_receiver_key, ) %}
{% endif %}

{% for f in keyfiles %}
"preseed-lib-copy-{{ f }}-{{ tmp_target }}":
  file.managed:
    - source: {{ f }}
    - name: {{ cs.target }}/{{ salt['cmd.run']('basename '+ f) }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - mode: 700
{% endfor %}

{% for f in ('Vagrantfile', 'options.include', 'load_kexec.sh', 'luksOpen.sh',
'nw_console.sh', 'set_diskpassword.sh', 'connect_new.sh', 'make_paper_config.sh','data2qrpdf.sh') %}

"preseed-lib-copy-{{ f }}-{{ tmp_target }}":
  file.managed:
    - source: "salt://preseed/files/{{ f }}"
    - name: {{ cs.target }}/{{ f }}
    - user: {{ ib_s.user }}
    - group: {{ ib_s.user }}
    - mode: 700
    - template: jinja
    - context:
        target: {{ cs.target }}
        cmdline: {{ cs.cmdline }}
        custom_ssh_identity: {{ cs.custom_ssh_identity|d("''") }}
        username: {{ cs.username|d("''") }}
        hostname: {{ cs.hostname|d("''") }}
        domainname: {{ cs.domainname|d("''") }}
        netcfg: {{ cs.netcfg }}
        disks: {{ cs.disks|d("/dev/vda") }}
        apt_proxy_mirror: {{ cs.apt_proxy_mirror|d("''") }}
        kernel_image: {{ cs.kernel_image|d("''") }}
        diskpassword_receiver_id: {{ cs.diskpassword_receiver_id|d("''") }}
        diskpassword_receiver_key: {{ cs.diskpassword_receiver_key|d("''") }}
        diskpassword_creation: {{ cs.diskpassword_creation|d("''") }}
{% endfor %}

{% endmacro %}
