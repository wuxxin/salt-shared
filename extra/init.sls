{# include additional states from pillar #}
{% if salt['pillar.get']('extra_states', False) %}
include:
  {%- for s in salt['pillar.get']('extra_states', []) %}
  - {{ s }}
  {%- endfor %}
{% endif %}

{# install additional packages from pillar #}
{% if salt['pillar.get']('extra_packages', False) %}
extra_packages:
  pkg.installed:
    - pkgs:
  {%- for pkg in salt['pillar.get']('extra_packages', []) %}
      - {{ pkg }}
  {%- endfor %}
{% endif %}
