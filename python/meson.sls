{% from 'python/lib.sls' import pip3_install %}
include:
  - python

meson-req:
  pkg.installed:
    - name: ninja-build

{{ pip3_install('meson', require= 'pkg: meson-req') }}
