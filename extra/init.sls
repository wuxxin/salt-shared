{% if pillar.get('extra_states', False) %}
include:
{% for state in pillar.get('extra_states', []) %}
  - {{ state }}
{% endfor %}
{% endif %}

{% for pkg in pillar.get('extra_packages', []) %}
{{ pkg }}:
  pkg.installed
{% endfor %}
