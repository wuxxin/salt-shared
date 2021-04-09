{% from 'python/lib.sls' import pip3_install %}
include:
  - python
  - python.ipython

python-dev:
  pkg.installed:
    - pkgs:
      - python3-dev
      - python3-pudb    {# full-screen console debugger for Python #}
      - cython3
    - require:
      - sls: python
