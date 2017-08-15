include:
  - python
  - python.ipython

python-dev:
  pkg.installed:
    - pkgs:
      - python-dev
      - python3-dev
    - require:
      - sls: python

{% from 'python/lib.sls' import pip2_install, pip3_install %}

{{ pip2_install('pudb') }}
{{ pip3_install('pudb') }}

{{ pip2_install('cgroup-utils', requires= ['pkg: python-dev']) }}
