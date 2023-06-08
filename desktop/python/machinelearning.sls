{# machinelearning #}
{% from 'aur/lib.sls' import aur_install with context %}

include:
  - desktop.python.scientific
  - hardware.amd.rocm.pytorch
  # - hardware.amd.rocm.tensorflow
  # - hardware.amd.rocm.jax

machinelearning_base:
  test.nop:
    - require:
      - sls: desktop.python.scientific

ml_tools:
  pkg.installed:
    - pkgs:
      # tensorboard - visualization and tooling needed for machine learning experimentation
      - tensorboard
    - require:
      - test: machinelearning_base

ml_scikit:
  pkg.installed:
    - pkgs:
      - python-scikit-learn
    - require:
      - test: machinelearning_base

ml_pytorch:
  test.nop:
    - require:
      - sls: hardware.amd.rocm.pytorch
      - test: machinelearning_base

# ml_tensorflow:
#   test.nop:
#     - require:
#       - sls: hardware.amd.rocm.tensorflow
#       - test: machinelearning_base

# ml_jax:
#   test.nop:
#     - require:
#       - sls: hardware.amd.rocm.jax
#       - test: machinelearning_base


{% load_yaml as pkgs %}
      # transformers - pretrained models to perform text, vision, and audio tasks for Jax, pytorch and tensorflow
      - python-transformers
      # tensorboardX - Tensorboard for PyTorch
      - python-tensorboardx
      # spacy - library for Natural Language Processing in Python
      - python-spacy
      # optuna - automatic hyperparameter optimization software framework
      - python-optuna
{% endload %}
{{ aur_install('ml_tools_aur', pkgs, require='pkg: ml_tools') }}

{% load_yaml as pkgs %}
      # Surprise - A Python scikit for building and analyzing recommender systems
      - python-scikit-surprise
{% endload %}
{{ aur_install('ml_scikit_extra_aur', pkgs, require='pkg: ml_scikit') }}

{% load_yaml as pkgs %}
      # torchtext - data processing utilities and popular datasets for natural language
      - python-torchtext
      # torchdata - modular data loading primitives for easily constructing flexible and performant data pipelines
      - python-torchdata
      # pytorch-lightning - lightweight PyTorch wrapper for high-performance AI research
      - python-pytorch-lightning
      # functorch - JAX-like composable function transforms for PyTorch
      - python-functorch
      # skorch - scikit-learn compatible neural network library that wraps PyTorch
      - python-skorch
      # albumentations - image augmentation to create new training samples from the existing data
      - python-albumentations
{% endload %}
{{ aur_install('ml_pytorch_aur', pkgs, require='test: ml_pytorch') }}

