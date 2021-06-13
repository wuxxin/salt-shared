{%- import_yaml "desktop/video/loopback/external.yml" as loopback_external %}
{%- load_yaml as settings %}
{# external software #}
external: {{ loopback_external.objects }}
{%- endload %}
{# expand ##version## in field external.*.download #}
{%- for n,v in settings.external.items() %}
  {%- set download=settings.external[n]['download']|regex_replace('##version##', v.version) %}
  {%- do settings.external[n].update( {'download': download} ) %}
{%- endfor %}

include:
  - kernel.running


kernel_module_requirements:
  pkg.installed:
    - pkgs:
      - build-essential
      - dkms
    - require:
      - sls: kernel.running

v4l2loopback:
  pkg.installed:
    - pkgs:
      - v4l2loopback-dkms
      - v4l2loopback-utils
    - require:
      - pkg: kernel_module_requirements

/etc/modules-load.d/v4l2loopback.conf:
  file.managed:
    - contents: |
        v4l2loopback

/etc/modprobe.d/v4l2loopback.conf:
  file.managed:
    - contents: |
        options v4l2loopback devices=1 exclusive_caps=1 video_nr=7 card_label="v4l2loopback"

akvcam:
  file.managed:
    - source: {{ settings.external['akvcam_tar_gz']['download'] }}
    - source_hash: sha256={{ settings.external['akvcam_tar_gz']['hash'] }}
    - name: {{ settings.external['akvcam_tar_gz']['target'] }}
  archive.extracted:
    - source: {{ settings.external['akvcam_tar_gz']['target'] }}
    - name: /usr/src/akvcam-{{ settings.external['akvcam_tar_gz']['version'] }}
    - archive_format: tar
    - enforce_toplevel: false
    - overwrite: true
    - options: --strip-components 2 --wildcards "*/src/"
    - onchange:
      - file: akvcam
  cmd.run:
    - name: /usr/lib/dkms/common.postinst akvcam \
            {{ settings.external['akvcam_tar_gz']['version'] }} \
            /usr/share/akvcam
    - onchange:
      - archive: akvcam
    - require:
      - pkg: kernel_module_requirements
