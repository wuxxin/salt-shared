{% if salt['pillar.get']('extra_packages', False) or salt['pillar.get']('extra_states', False) %}
include:
{% for s in salt['pillar.get']('extra_states', []) %}
  - {{ s }}
{% endfor %}
{% if salt['pillar.get']('extra_packages', False) %}
  - .extra_packages
{% endif %}
{% endif %}
