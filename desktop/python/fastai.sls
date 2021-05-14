{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python.jupyter

{# fastai requirements
fastcore torch>=1.3.0 torchvision>=0.5 matplotlib pandas requests pyyaml
fastprogress>=0.1.22 pillow scikit-learn scipy spacy
#}

{{ pipx_inject('scipy',
  ['fastscript', 'ndbdev', 'torch', 'torchvision', 'spacy', 'fastai'],
  require='sls:desktop.python.jupyter', user=user) }}
