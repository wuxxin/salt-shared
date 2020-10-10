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

{% load_yaml as settings %}
external:
  akvcam_tar_gz:
    version: 1.1.0
    latest: curl -L -s "https://github.com/webcamoid/akvcam/releases" | hxwls | grep "/releases/tag/" | head -n 1 | sed -r "s/.*\/([^\/]+)$/\1/g"
    download: "https://github.com/webcamoid/akvcam/archive/##version##.tar.gz"
    target: /usr/local/lib/akvcam.tar.gz
    hash: 800fb6427e436b81b9c0cfa9925e0e32ee2bde3448085f059fa00ef6f7ea0af9
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
