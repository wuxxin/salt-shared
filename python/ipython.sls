include:
  - python

{% from 'python/lib.sls' import pip3_install %}

{{ pip3_install(['ipython', 'jupyter', 'ipdb']) }}
