{% from 'python/lib.sls' import pip_install %}
include:
  - python

{% if grains['os'] == 'Ubuntu' %}

meson-req:
  pkg.installed:
    - name: ninja-build

{{ pip_install('meson', require= 'pkg: meson-req') }}

{% else %}

meson:
  pkg:
    - installed

{% endif %}
