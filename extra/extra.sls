{% if pillar.get('extra_packages', False) or pillar.get('extra_states', False) %}
include:
{% for s in pillar.get('extra_states', []) %}
  - {{ s }}
{% endfor %}
{% if pillar.get('extra_packages', False) %}
  - .extra_packages
{% endif %}
{% endif %}
