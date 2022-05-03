{% from "python/defaults.jinja" import settings with context %}
{% from 'python/lib.sls' import pip_install %}

include:
  - python
  - python.ipython

python-dev:
  pkg.installed:
    - pkgs: {{ settings.python_dev[grains['os_family']|lower] }}

{% if grains['os'] == 'Ubuntu' %}

meson-req:
  pkg.installed:
    - name: ninja-build

{{ pip_install('meson', require= 'pkg: meson-req') }}

{% endif %}
