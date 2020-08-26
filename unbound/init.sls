{% from "unbound/defaults.jinja" import settings with context %}

include:
  - ubuntu

{% if grains['osrelease_info'][0]|int <= 18 %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("unbound_ppa", "ondrej/unbound",
  require_in = "pkg: unbound") }}
{% endif %}

unbound:
  pkg:
    - installed
  service:
{% if settings.enabled|d(false) %}
    - running
{%- else %}
    - dead
{% endif %}
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

{% if settings.enabled|d(false) %}

/etc/systemd/resolved.conf.d/dns_servers.conf:
  file:
  {%- if settings.redirect_host_dns %}
    - managed
    - makedirs: true
    - contents: |
        [Resolve]
        DNS={{ settings.listen[0] }}
  {%- else %}
    - absent
  {%- endif %}
  cmd.run:
    - name: systemctl restart systemd-resolved
    - onchange:
      - file: /etc/systemd/resolved.conf.d/dns_servers.conf

{% endif %}
