{% from "unbound/defaults.jinja" import settings with context %}

{% if grains['os'] == 'Ubuntu' %}
{% if grains['oscodename'] in ['xenial','bionic','focal'] %}
{# unbound 1.12 is available as backport for xenial, bionic, focal #}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("unbound_ppa", "emetriq/unbound-backport", require_in = "pkg: unbound") }}
{% endif %}
{% endif %}

unbound:
  pkg:
    - installed
  service:
{% if settings.enabled %}
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

/etc/systemd/resolved.conf.d/unbound_dns_server.conf:
  file:
{%- if settings.enabled and settings.redirect_host_dns %}
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
    - onchanges:
      - file: /etc/systemd/resolved.conf.d/dns_servers.conf
