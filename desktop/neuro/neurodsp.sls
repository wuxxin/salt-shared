{% from 'python/lib.sls' import pip3_install %}
include:
  - python.scientific

{{ pip3_install('neurodsp', require='sls: python.scientific') }}
