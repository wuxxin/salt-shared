
{% set shorewall_parts = ["interfaces", "policy", "tunnels", "rules", "masq", "zones"] %}
{% set shorewall_scripts = ["init", "stop", "start"] %}

shorewall:
  pkg:
    - installed
    - name: shorewall
  service.running:
    - enable: True
    - require:
      - pkg: shorewall
    - watch:
{%- for name in shorewall_parts %}
      - file: /etc/shorewall/{{ name }}
{%- endfor %}
{%- for name in shorewall_scripts %}
{%- if salt['pillar.get']("shorewall:files:"+ name) is defined %}
      - file: /etc/shorewall/{{ name }}
{%- endif %}
{%- endfor %}
      - file: /etc/default/shorewall
      - file: /etc/shorewall/shorewall.conf

/etc/default/shorewall:
  file.replace:
    - pattern: "^#?[\t ]*startup=.*"
    - repl: startup=1
    - append_if_not_found: true
    - backup: false

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
/etc/shorewall/shorewall.conf:
  file.replace:
    - pattern: "^#?[\t ]*LOGFILE=.*"
    - repl: LOGFILE=/var/log/syslog
    - append_if_not_found: true
{% endif %}

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

{%- for name in shorewall_scripts %}
{%- if salt['pillar.get']("shorewall:files:"+ name) is defined %}
/etc/shorewall/{{ name }}:
  file.managed:
    - contents: |
{{ salt['pillar.get']("shorewall:files:"+ name)|indent(8, True) }}
    - mode: "0755"
  require:
    - pkg: shorewall
{%- endif %}
{%- endfor %}
