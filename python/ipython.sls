include:
  - python

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip3_install(['ipython', 'jupyter', 'ipdb']) }}
