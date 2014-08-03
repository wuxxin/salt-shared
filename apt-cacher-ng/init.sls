apt-cacher-ng:
  pkg:
    - installed
  service:
    - running
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

{% if pillar.get('apt-cacher-ng:bindaddress') != '' %}
/etc/apt-cacher-ng/acng.conf:
  file.replace:
    - pattern: "^.*BindAddress:.*$"
{% if pillar.get('apt-cacher-ng:bindaddress') != '' %}
    - repl: "BindAddress: localhost {{ salt['pillar.get']('apt-cacher-ng:bindaddress') }}"
{% else %}
    - repl: "#BindAddress: "
{% endif %}
    - require:
      - pkg: apt-cacher-ng
    - watch_in:
      - service: apt-cacher-ng
{% endif %}

{% if pillar.get('apt-cacher-ng:custom_storage') != '' %}
{% from 'storage/lib.sls' import storage_setup with context %}
{{ storage_setup(pillar.get('apt-cacher-ng:custom_storage')) }}
{% endif %}
