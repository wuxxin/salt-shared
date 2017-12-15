{% from "http_proxy/defaults.jinja" import settings as s with context %}

{% if (grains['lsb_distrib_codename'] == "trusty") %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("polipo_ppa", 
  "phraktle/backports", require_in= "pkg: polipo") }}
{% endif %}

polipo:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: polipo
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
        maxDiskCacheEntrySize = {{ s.maxDiskCacheEntrySize }}

    - require:
      - pkg: polipo


{% if salt['pillar.get']('polipo:server:custom_storage', false) %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(salt['pillar.get']('polipo:server:custom_storage')) }}
{% endif %}
