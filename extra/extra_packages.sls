{% if salt['pillar.get']('extra_packages', False) %}

{% for pkg in salt['pillar.get']('extra_packages', []) %}
{{ pkg }}:
  pkg.installed
{% endfor %}

{% endif %}
