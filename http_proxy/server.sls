{% from "http_proxy/defaults.jinja" import settings as s with context %}

squid:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: squid
    - watch:
      - file: /etc/squid/squid.conf

/etc/squid/conf.d/salt.conf:
  file.managed:
    - contents: |
        proxyAddress = {{ s.bindaddress }}
        proxyPort = {{ s.bindport }}
        diskCacheRoot = {{ s.diskCacheRoot }}
        maxDiskCacheEntrySize = {{ s.maxDiskCacheEntrySize }}

    - require:
      - pkg: squid


{% if salt['pillar.get']('squid:server:custom_storage', false) %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(salt['pillar.get']('squid:server:custom_storage')) }}
{% endif %}
