include:
  - python
  - .flatyaml
  - .ravencat

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('percol') }}


