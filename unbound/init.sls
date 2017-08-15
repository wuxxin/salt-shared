include:
  - ubuntu

{% from "unbound/defaults.jinja" import settings as s with context %}

{% if s.active|d(false) == true %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("nlnetlabs-ppa", "ondrej/pkg-nlnetlabs") }}


unbound:
  pkg.installed:
    - require:
      - pkgrepo: nlnetlabs-ppa
  service.running:
    - require:
      - pkg: unbound
    - watch:
      - file: unbound
      - file: /etc/default/unbound
  file.managed:
    - name: /etc/unbound/unbound.conf.d/unbound.conf
    - source: salt://dns/server/unbound.conf
    - template: jinja
    - context:
        cache: {{ k.cache }}

default_unbound_resolvconf:
  file.replace:
    - name: /etc/default/unbound
    - pattern: |
        ^#?[ \t]*RESOLVCONF=.*
    - repl: |
        RESOLVCONF={{ "true" if k.cache.redirect_host_dns == true else "false" }}
    - require:
      - pkg: unbound

default_unbound_RESOLVCONF_FORWARDERS:
  file.replace:
    - name: /etc/default/unbound
    - pattern: |
        ^#?[ \t]*RESOLVCONF_FORWARDERS=.*
    - repl: |
        RESOLVCONF_FORWARDERS=false
    - require:
      - pkg: unbound


{% endif %}
