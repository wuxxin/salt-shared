{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python.jupyter

{# machine learning #}
{{ pipx_inject('jupyterlab', [
  'sklearn', 'sklearn-pandas', 'auto-sklearn',
  'tensorflow', 'tensorboard', 'tensorflow_hub',
  'torch', 'torchvision', 'torchaudio', 'torchtext',
  'fastai',
  'statsmodels',
  ], require='sls: desktop.python.jupyter', user=user) }}
