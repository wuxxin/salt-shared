{% from "http_proxy/defaults.jinja" import settings as s with context %}

include:
  - .ppa


polipo:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: polipo
{%- if (grains['lsb_distrib_codename'] == "trusty") %}
      - cmd: polipo_ppa
{% endif %}
    - watch:
      - file: /etc/polipo/config

/etc/polipo/config:
  file.managed:
    - contents: |
        logSyslog = false
        logFile = /var/log/polipo/polipo.log
        proxyAddress = {{ s.bindaddress }}
        proxyPort = {{ s.bindport }}
        cacheIsShared = {{ s.cacheIsShared }}
        disableIndexing = {{ s.disableIndexing }}
        disableServersList = {{ s.disableServersList }}
        diskCacheRoot = {{ s.diskCacheRoot }}

    - require:
      - pkg: polipo


{% if salt['pillar.get']('polipo:server:custom_storage', false) %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(salt['pillar.get']('polipo:server:custom_storage')) }}
{% endif %}
