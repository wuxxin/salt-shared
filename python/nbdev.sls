{% from 'python/lib.sls' import pip3_install %}

include:
  - python.ipython

nbdev:
  pkg.installed:
    - pkgs:
      - python3-nbformat
      - python3-nbconvert
      - python3-yaml
      - python3-packaging

{{ pip3_install('fastscript', require='pkg: nbdev') }}
{{ pip3_install('nbdev', require= ['pkg: nbdev', 'pip: fastscript']) }}
