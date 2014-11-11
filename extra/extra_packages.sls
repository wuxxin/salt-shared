{% if pillar.get('extra_packages', False) %}

{% for pkg in pillar.get('extra_packages', []) %}
{{ pkg }}:
  pkg.installed
{% endfor %}
