include:
  - .init

# preseed_make
###############

{% macro preseed_make(cs) %}

{% from "roles/imgbuilder/preseed/defaults.jinja" import template with context %}
{% set settings=salt['grains.filter_by']({'none': template },
  grain='none', default= 'none', merge= cs|d({})) %}

{{ initrd_unpack(cs) }}
{{ add_preseed_files(cs) }}
{{ initrd_pack(cs) }}

{% endmacro %}


{% macro initrd_unpack(cs) %}

{% set tmp_target="/mnt/images/tmp/initrd-"+ cs.suite+ "-"+ cs.architecture %}
{% set netboot_target="/mnt/images/tmp/netboot-"+ cs.suite+ "-"+ cs.architecture %}

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


{% macro add_preseed_files(cs) %}

{% set tmp_target="/mnt/images/tmp/initrd-"+ cs.suite+ "-"+ cs.architecture %}

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
        password: {{ cs.password|d(" ") }}
        username: {{ cs.username|d(" ") }}
        hostname: {{ cs.hostname|d(" ") }}
        domainname: {{ cs.domainname|d(" ") }}
        netcfg: {{ cs.netcfg }}
        diskpassword: {{ cs.diskpassword|d(" ") }}
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
{% for l in cs.additional_layers %}
overlay-install-{{ l }}:
  cmd.run:
sdfgsfgklj replace with tar because extract does not want already populated dir
    - name: tar xzf {{ l }}{{ tmp_target }}
    - source: {{ l }}
    - user: imgbuilder
    - group: imgbuilder
    - archive_format: tar
    - tar_options: z
{% endfor %}

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
{% endfor %}
{% endif %}

# make /custom/custom.lst 
make-custom-list:
  cmd.run:
    - name: cd {{ tmp_target }}/custom; ls * > custom.lst

{% endmacro %}


{% macro initrd_pack(cs) %}

{% set tmp_target="/mnt/images/tmp/initrd-"+ cs.suite+ "-"+ cs.architecture %}
{% set netboot_target="/mnt/images/tmp/netboot-"+ cs.suite+ "-"+ cs.architecture %}

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

{% endmacro %}
