apt-cacher-ng:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: apt-cacher-ng
    - watch:
      - file: /etc/default/apt-cacher-ng

/etc/default/apt-cacher-ng:
  file.replace:
    - pattern: ^DISABLED=1
    - repl: #DISABLED=1
    - require:
      - pkg: apt-cacher-ng

{# 
Update mine data: send data back to master after debian install package,
so we have fresh mine data for minions requesting the hostname of the cache service
#}
update-mine:
  module.run:
    - name: mine.update
    - require:
      - pkg: apt-cacher-ng

{% if salt['pillar.get']('apt-cacher-ng:server:bindaddress', false) %}
/etc/apt-cacher-ng/acng.conf:
  file.replace:
    - pattern: "^.*BindAddress:.*$"
{% if salt['pillar.get']('apt-cacher-ng:server:bindaddress') != '' %}
    - repl: "BindAddress: localhost {{ salt['pillar.get']('apt-cacher-ng:server:bindaddress') }}"
{% else %}
    - repl: "#BindAddress: "
{% endif %}
    - require:
      - pkg: apt-cacher-ng
    - watch_in:
      - service: apt-cacher-ng
{% endif %}

# FIXME: add some workarounds for https apt references, eg.
# PassThroughPattern: private-ppa\.launchpad\.net:443$

{% if salt['pillar.get']('apt-cacher-ng:server:custom_storage', false) %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(salt['pillar.get']('apt-cacher-ng:server:custom_storage')) }}
{% endif %}
