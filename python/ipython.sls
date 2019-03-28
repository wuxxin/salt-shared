include:
  - python

ipython:
  pkg.installed:
    - pkgs:
      - ipython3
      - python3-ipdb
      
{%- if grains['osmajorrelease']|int >= 18 %}
jupyter:
  pkg.installed:
    - name: jupyter
{%- endif %}
