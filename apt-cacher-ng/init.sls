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

symlink-to-cache:
  file.directory:
    - name: /mnt/cache/apt-cacher-ng
    - user: apt-cacher-ng
    - group: apt-cacher-ng
    - dir_mode: 2755
  cmd.run:
    - name: rm -r /var/cache/apt-cacher-ng; ln -s -T /mnt/cache/apt-cacher-ng /var/cache/apt-cacher-ng
    - unless: test -L /var/cache/apt-cacher-ng
    - require:
      - file: symlink-to-cache
    - watch_in:
      - service: apt-cacher-ng



