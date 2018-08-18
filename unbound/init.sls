include:
  - ubuntu

{% from "unbound/defaults.jinja" import settings as s with context %}

{% if s.enabled|d(false) == true %}

  {% if grains['osrelease_info'][0]|int <= 18 %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("unbound-ppa", "ondrej/unbound",
  require_in = "pkg: unbound") }}
  {% endif %}
  
unbound:
  pkg:
    - installed
  service.running:
    - require:
      - pkg: unbound
    - watch:
      - file: unbound
      - file: /etc/default/unbound
  file.managed:
    - name: /etc/unbound/unbound.conf.d/unbound.conf
    - source: salt://unbound/unbound.conf
    - template: jinja
    - context:
        settings: {{ s }}
    - check_cmd: unbound-checkconf
    - require:
      - pkg: unbound

default_unbound_resolvconf:
  file.replace:
    - name: /etc/default/unbound
    - append_if_not_found: true
    - pattern: |
        ^#?[ \t]*RESOLVCONF=.*
    - repl: |
        RESOLVCONF={{ "true" if s.redirect_host_dns == true else "false" }}
    - require:
      - pkg: unbound

default_unbound_RESOLVCONF_FORWARDERS:
  file.replace:
    - name: /etc/default/unbound
    - append_if_not_found: true
    - pattern: |
        ^#?[ \t]*RESOLVCONF_FORWARDERS=.*
    - repl: |
        RESOLVCONF_FORWARDERS=false
    - require:
      - pkg: unbound

{% endif %}
