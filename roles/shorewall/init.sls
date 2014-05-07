
{% set shorewall_parts = ["interfaces", "policy", "tunnels", "rules", "masq", "zones"] %}

shorewall:
  pkg:
    - installed
    - name: shorewall
  service.running:
    - enable: True
    - require:
      - pkg: shorewall
    - watch:
{% for name in shorewall_parts %}
      - file: /etc/shorewall/{{ name }}
{% endfor %}


{% for name in shorewall_parts %}

/etc/shorewall/{{ name }}:
  file.managed:
    - source: salt://roles/shorewall/files/{{ name }}
    - template: jinja
    - context: 
      shorewall: {{ pillar.shorewall }}
  require:
      - pkg: shorewall

{% endfor %}
