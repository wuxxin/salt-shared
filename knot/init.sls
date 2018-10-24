include:
  - ubuntu

{% from "knot/defaults.jinja" import settings as s with context %}
{% from "ubuntu/init.sls" import apt_add_repository %}

{# knot from ppa is newer even for cosmic #}
{{ apt_add_repository("knot-ppa", "cz.nic-labs/knot-dns",
  require_in = "pkg: knot-package") }}

knot-package:
  pkg.installed:
    - names:
      - knot
    - require:
      - pkgrepo: knot-ppa

knot-config-check:
  file.managed:
    - name: /usr/sbin/knot-config-check
    - contents: |
        #!/bin/sh
        /usr/sbin/knotc -c $1 conf-check
        exit $?
    - mode: "0755"
    - require:
      - pkg: knot-package

/etc/default/knot:
  file.managed:
    - name: /etc/default/knot
    - contents: |
        KNOTD_ARGS="-c /etc/knot/knot.conf"
        #

{% if s.enabled|d(false) %}

/etc/knot/knot.conf:
  file.managed:
    - name: 
    - source: salt://knot/knot.jinja
    - template: jinja
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
    - context:
        server: {{ config }}
    - check_cmd: /usr/sbin/knot-config-check
    - require:
      - file: knot-config-check

  {%- for zone in s.zone %}
knot-zone-{{ zone.domain }}:
      {%- set targetfile = '/var/lib/knot/' + zone.template|d('default')+ '/'+ zone.domain+ '.zone' %}
      {%- if zone.source is not defined %}
  file.present:
    - name: {{ targetfile }}
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
      {%- else %}
  file.managed:
    - name: {{ targetfile }}
    - template: jinja
    - source: {{ zone.source }}
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
    - watch_in: knot.service
    - context:
        common: {{ s.common }}
    - check_cmd: kzonecheck {{ zone.domain }} FIXME check param
      {%- endif %}
  {%- endfor %}
  
knot:
  service.running:
    - enable: true
    - require:
      - pkg: knot-package
    - watch:
      - file: /etc/default/knot
      - file: /etc/knot/knot.conf

{%- else %}
knot:
  service.dead:
    - disable: true

/etc/knot/knot.conf:
  file:
    - absent

{%- endif %}
