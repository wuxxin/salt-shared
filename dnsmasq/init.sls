dnsmasq:
  pkg:
    - installed

{% if salt['pillar.get']('dnsmasq:config', False) %}
create_dnsmasq_conf:
  file.managed:
    - name: /etc/dnsmasq.d/dnsmasq.conf
    - makedirs: True
    - contents: |
{{ salt['pillar.get']('dnsmasq:config')|indent(8, True) }}

{% endif %}
