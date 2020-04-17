include:
  - python
  - python.jinja2

ipython:
  pkg.installed:
    - pkgs:
      - ipython3
      - python3-ipdb
{%- if grains['osmajorrelease']|int >= 18 %}
      - python3-ipykernel

jupyter:
  pkg.installed:
    - pkgs:
      - jupyter
      - jupyter-notebook

{%- endif %}
