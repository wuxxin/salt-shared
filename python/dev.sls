{% from "python/defaults.jinja" import settings with context %}
{% from 'python/lib.sls' import pip_install %}

include:
  - python
  - python.ipython
  - python.meson

python-dev:
  pkg.installed:
    - pkgs: {{ settings.python_dev[grains['os_family']|lower] }}
