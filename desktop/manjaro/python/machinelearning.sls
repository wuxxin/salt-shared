{# machinelearning #}
{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - desktop.manjaro.python.scientific
  - hardware.amd.rocm.pytorch
  - hardware.amd.rocm.tensorflow

ml_tools:
  pkg.installed:
    - pkgs:
      # tensorboard - visualization and tooling needed for machine learning experimentation
      - tensorboard
    - require:
      - test: scientific_python
{% load_yaml as pkgs %}
      # tensorboardX - Tensorboard for PyTorch
      - python-tensorboardx
      # spacy - library for Natural Language Processing in Python
      - python-spacy
      # transformers - pretrained models to perform text, vision, and audio tasks for Jax, pytorch and tensorflow
      - transformers
{% endload %}
{{ pamac_install('ml_tools_aur', pkgs, require='pkg: ml_tools') }}

ml_sklearn:
  pkg.installed:
    - pkgs:
      - python-scikit-learn
    - require:
      - test: scientific_python
      - test: ml_tools_aur
{% load_yaml as pkgs %}
      ## sklearn
      - python-sklearn-pandas
{% endload %}
{{ pamac_install('ml_sklearn_aur', pkgs, require='pkg: ml_sklearn') }}

ml_tensorflow:
  test.nop:
    - require:
      - test: scientific_python
      - test: ml_tools_aur
      - sls: hardware.amd.rocm.tensorflow

ml_pytorch:
  test.nop:
    - require:
      - test: scientific_python
      - test: ml_tools_aur
      - sls: hardware.amd.rocm.pytorch

{% load_yaml as pkgs %}
      # torchtext - data processing utilities and popular datasets for natural language
      - python-torchtext
      # torchdata - modular data loading primitives for easily constructing flexible and performant data pipelines
      - python-torchdata
      # functorch - JAX-like composable function transforms for PyTorch
      - python-functorch
      # pytorch-lightning - lightweight PyTorch wrapper for high-performance AI research
      - python-pytorch-lightning
      # kornia - classical computer vision integrated into deep learning models
      - python-kornia
      # skorch - scikit-learn compatible neural network library that wraps PyTorch
      - python-skorch
{% endload %}
{{ pamac_install('ml_pytorch_extra_aur', pkgs,
    require=['test: ml_pytorch', 'test: ml_tools_aur']) }}

# fastai - simplifies training fast and accurate neural nets using modern best practices
{{ pamac_patch_install_dir('python-fastcore',
    'salt://desktop/manjaro/python/python-fastcore',
    require= 'test: ml_pytorch_extra_aur') }}
{{ pamac_patch_install_dir('python-fastai2',
    'salt://desktop/manjaro/python/python-fastai2',
    require= 'test: python-fastcore') }}
