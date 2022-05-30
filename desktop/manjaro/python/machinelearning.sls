{# machinelearning #}
{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - desktop.manjaro.python.scientific
  - hardware.amd.rocm.pytorch

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
      - python-transformers
      # optuna - automatic hyperparameter optimization software framework
      - python-optuna
{% endload %}
{{ pamac_install('ml_tools_aur', pkgs, require='pkg: ml_tools') }}

ml_sklearn:
  pkg.installed:
    - pkgs:
      - python-scikit-learn
    - require:
      - test: scientific_python
      - test: ml_tools_aur

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
      # skorch - scikit-learn compatible neural network library that wraps PyTorch
      - python-skorch
      # albumentations - image augmentation to create new training samples from the existing data
      - python-albumentations
{% endload %}
{{ pamac_install('ml_pytorch_extra_aur', pkgs,
    require=['test: ml_pytorch', 'test: ml_tools_aur']) }}
