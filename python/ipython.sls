{% from "python/defaults.jinja" import settings with context %}

include:
  - python
  - python.jinja

ipython:
  pkg.installed:
    - pkgs: {{ settings.ipython[grains['os_family']|lower] }}
