{% from "knot/defaults.jinja" import settings with context %}
{% from "knot/defaults.jinja" import log_default, template_default %}
{% from "knot/zone.sls" import write_zone %}

{% from "ubuntu/init.sls" import apt_add_repository %}

{# knot from ppa is newer for almost any distro #}
{{ apt_add_repository("knot_ppa", "cz.nic-labs/knot-dns-latest",
  require_in = "pkg: knot-package") }}

knot-package:
  pkg.installed:
    - names:
      - knot
      - knot-dnsutils
      - knot-doc
      - knot-host

knot-config-check:
  file.managed:
    - name: /usr/local/sbin/knot-config-check
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

{% if settings.enabled|d(true) %}
  {%- for zone in settings.zone %}
{{ write_zone(zone, settings.common, watch_in="knot.service") }}
  {%- endfor %}

/etc/knot/knot.conf:
  file.managed:
    - source: salt://knot/knot.jinja
    - template: jinja
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
    - defaults:
        settings: {{ settings }}
        log_default: {{ log_default }}
        template_default: {{ template_default }}
    - check_cmd: /usr/local/sbin/knot-config-check
    - require:
      - file: knot-config-check

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
