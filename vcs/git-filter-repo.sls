{% from 'python/lib.sls' import pip3_install %}

include:
  - python

{{ pip3_install('git-filter-repo') }}
