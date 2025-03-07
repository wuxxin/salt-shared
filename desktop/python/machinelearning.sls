{# machinelearning #}
{% from 'arch/lib.sls' import aur_install with context %}

include:
  - desktop.python.scientific
  - hardware.amd.rocm.pytorch
  # - hardware.amd.rocm.tensorflow
  - hardware.amd.rocm.cupy
  - hardware.amd.rocm.onnx
  # - hardware.amd.rocm.localai
  - hardware.amd.rocm.koboldcpp
  - hardware.amd.rocm.ollama

ml_pytorch:
  test.nop:
    - require:
      - sls: hardware.amd.rocm.pytorch
      - sls: desktop.python.scientific

ml_tensorflow:
  test.nop:
    - require:
      # - sls: hardware.amd.rocm.tensorflow
      - sls: desktop.python.scientific

ml_scikit:
  pkg.installed:
    - pkgs:
      - python-scikit-learn
    - require:
      - sls: desktop.python.scientific

ml_base:
  test.nop:
    - require:
      - test: ml_pytorch
      # - test: ml_tensorflow
      - pkg: ml_scikit
      - sls: hardware.amd.rocm.cupy
      - sls: hardware.amd.rocm.onnx
      # - sls: hardware.amd.rocm.localai
      - sls: hardware.amd.rocm.koboldcpp
      - sls: hardware.amd.rocm.ollama

ml_libraries:
  pkg.installed:
    - pkgs:
      # python-tiktoken - A fast BPE tokeniser for use with OpenAI's models
      - python-tiktoken
      # tensorboard - visualization and tooling needed for machine learning experimentation
      - tensorboard
    - require:
      - test: ml_base
{% load_yaml as pkgs %}
      # python-transformers - State-of-the-art Natural Language Processing for Jax, PyTorch and TensorFlow
      - python-transformers
      # python-deepspeed - DeepSpeed is a deep learning optimization library for distributed training and inference
      # - python-deepspeed
{% endload %}
{{ aur_install('ml_libraries_aur', pkgs, require='pkg: ml_libraries') }}

# ml_pytorch_aur
{% load_yaml as pkgs %}
      # python-accelerate - simple way to train and use PyTorch models with multi-GPU, TPU, mixed-precision
      - python-accelerate
      # torchtext - data processing utilities and popular datasets for natural language
      - python-torchtext
      # torchdata - modular data loading primitives for easily constructing flexible and performant data pipelines
      - python-torchdata
      # pytorch-lightning - lightweight PyTorch wrapper for high-performance AI research
      - python-pytorch-lightning
      # functorch - JAX-like composable function transforms for PyTorch
      - python-functorch
      # skorch - scikit-learn compatible neural network library that wraps PyTorchhttps://gandalf.lakera.ai/
      - python-skorch
      # python-sentence-transformers - Multilingual Sentence & Image Embeddings with BERT
      - python-sentence-transformers
{% endload %}
{{ aur_install('ml_pytorch_aur', pkgs, require='test: ml_pytorch') }}

# ml_tools_aur
{% load_yaml as pkgs %}
      # aichat - Using ChatGPT/GPT-3.5/GPT-4 in the terminal
      - aichat
      # mods - AI for the command line, built for pipelines
      - mods
      # chatgpt.sh - Shell wrapper for OpenAI's ChatGPT, DALL-E, Whisper, and TTS.
      - chatgpt.sh
{% endload %}
{{ aur_install('ml_tools_aur', pkgs) }}

# ml_scikit_aur
{% load_yaml as pkgs %}
      # Surprise - A Python scikit for building and analyzing recommender systems
      - python-scikit-surprise
{% endload %}
{{ aur_install('ml_scikit_aur', pkgs, require='pkg: ml_scikit') }}
