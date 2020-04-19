{% from 'python/lib.sls' import pip3_install %}

include:
  - python.scientific
  - python.nbdev

{# fastai2 requirements
fastcore torch>=1.3.0 torchvision>=0.5 matplotlib pandas requests pyyaml
fastprogress>=0.1.22 pillow scikit-learn scipy spacy
#}

{{ pip3_install('torch', require='sls: python.scientific') }}
{{ pip3_install('torchvision', require='pip: torch') }}
{{ pip3_install('spacy', require='pip: torch') }}
{{ pip3_install('fastai2', require=['sls: python.nbdev', 'pip: spacy']) }}
