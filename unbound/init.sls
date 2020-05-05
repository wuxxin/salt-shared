include:
  - ubuntu

{% from "unbound/defaults.jinja" import settings with context %}

{% if settings.enabled|d(false) %}

  {% if grains['osrelease_info'][0]|int <= 18 %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("unbound_ppa", "ondrej/unbound",
  require_in = "pkg: unbound") }}
  {% endif %}

unbound:
  pkg:
    - installed
  service.running:
    - require:
      - pkg: unbound
    - watch:
      - file: /etc/unbound/unbound.conf.d/unbound.conf

/etc/unbound/unbound.conf.d/unbound.conf:
  file.managed:
    - source: salt://unbound/unbound.conf
    - template: jinja
    - context:
        settings: {{ settings }}
    - check_cmd: unbound-checkconf
    - require:
      - pkg: unbound

{% endif %}
