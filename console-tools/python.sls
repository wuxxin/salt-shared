include:
  - python
  - .flatyaml
  - .raven

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('percol') }}


