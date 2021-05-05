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

{% load_yaml as settings %}
external:
  akvcam_tar_gz:
    version: 1.2.0
    latest: curl -L -s "https://github.com/webcamoid/akvcam/releases" | hxwls | grep "/releases/tag/" | head -n 1 | sed -r "s/.*\/([^\/]+)$/\1/g"
    download: "https://github.com/webcamoid/akvcam/archive/##version##.tar.gz"
    target: /usr/local/lib/akvcam.tar.gz
    hash: 6a6591ccde53bc47277be85c5f1a974fafd737f366c13a28b01d45611b30c0fb
{% endload %}
{# expand ##version## in field external.*.download #}
{% for n,v in settings.external.items() %}
  {% set dummy=settings.external[n].__setitem__('download',
        v['download']|regex_replace('##version##', v.version)) %}
{% endfor %}

{% set external = settings.external.akvcam_tar_gz %}

akvcam:
  file.managed:
    - source: {{ external.download }}
    - source_hash: sha256={{ external.hash }}
    - name: {{ external.target }}
  archive.extracted:
    - source: {{ external.target }}
    - name: /usr/src/akvcam-{{ external.version }}
    - archive_format: tar
    - enforce_toplevel: false
    - overwrite: true
    - options: --strip-components 2 --wildcards "*/src/"
    - onchange:
      - file: akvcam
  cmd.run:
    - name: /usr/lib/dkms/common.postinst akvcam {{ external.version }} /usr/share/akvcam
    - onchange:
      - archive: akvcam
    - require:
      - pkg: kernel_module_requirements
