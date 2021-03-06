{% from 'python/lib.sls' import pip3_install %}
include:
  - python
  - python.ipython
  - python.meson

python-dev:
  pkg.installed:
    - pkgs:
      - build-essential
      - python3-dev
      - python3-pudb    {# full-screen console debugger for Python #}
      - cython3   {# syntax very similar to python for wrapping external C libraries and fast C modules #}
    - require:
      - sls: python
