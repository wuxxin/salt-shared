{% from 'python/lib.sls' import pip_install %}

include:
  - python

{{ pip_install('git-filter-repo') }}
