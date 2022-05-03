{# machinelearning #}
{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - desktop.manjaro.python.scientific
  - hardware.amd.rocm.pytorch
  # - hardware.amd.rocm.tensorflow


ml_tools:
  pkg.installed:
    - pkgs:
      ## tensorboard - visualization and tooling needed for machine learning experimentation
      - tensorboard
    - require:
      - test: scientific_python
{% load_yaml as pkgs %}
      ## tensorboardX - Tensorboard for PyTorch
      - python-tensorboardx
      ## spacy - library for Natural Language Processing in Python
      - python-spacy
      ## transformers - pretrained models to perform text, vision, and audio tasks for Jax, pytorch and tensorflow
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
      # auto-sklearn
{% endload %}
{{ pamac_install('ml_sklearn_aur', pkgs, require='pkg: ml_sklearn') }}


ml_tensorflow:
  test.nop:
    - require:
      - test: scientific_python
      - test: ml_tools_aur
      # - sls: hardware.amd.rocm.tensorflow


ml_pytorch:
  test.nop:
    - require:
      - test: scientific_python
      - test: ml_tools_aur
      - sls: hardware.amd.rocm.pytorch

{% load_yaml as pkgs %}
      ## torchtext - data processing utilities and popular datasets for natural language
      - python-torchtext
      ## torchdata - modular data loading primitives for easily constructing flexible and performant data pipelines
      - python-torchdata
      ## functorch - JAX-like composable function transforms for PyTorch
      - python-functorch
      ## pytorch-lightning - lightweight PyTorch wrapper for high-performance AI research
      - python-pytorch-lightning
      ## kornia - classical computer vision integrated into deep learning models
      - python-kornia
      ## skorch - scikit-learn compatible neural network library that wraps PyTorch
      - python-skorch
{% endload %}
{{ pamac_install('ml_pytorch_extra_aur', pkgs,
    require=['test: ml_pytorch', 'test: ml_tools_aur']) }}

## fastai - simplifies training fast and accurate neural nets using modern best practices
{{ pamac_patch_install_dir('python-fastcore',
    'salt://desktop/manjaro/python/python-fastcore',
    require= 'test: ml_pytorch_extra_aur') }}
{{ pamac_patch_install_dir('python-fastai2',
    'salt://desktop/manjaro/python/python-fastai2',
    require= 'test: python-fastcore') }}


{#

# torch related
optuna            # hyperparameter optimization framework to automate hyperparameter search
pytorchvideo      # a deeplearning library with a focus on video understanding work
detectron2        # Facebook AI Research's next generation library that provides state-of-the-art detection and segmentation algorithms
torch-geometric   # PyTorch Geometric (PyG) is a geometric deep learning extension library for PyTorch
monai             # Medical Open Network for AI for pytorch
flair             # A very simple framework for state-of-the-art NLP. Developed by Humboldt University of Berlin and friends
allennlp          # A natural language processing platform for building state-of-the-art models
vissl             # A computer VIsion library for state-of-the-art Self-Supervised Learning research with PyTorch
albumentations    # a library for image augmentation to create new training samples from the existing data
pfrl              # a deep reinforcement learning library that implements various state-of-the-art deep reinforcement algorithms
parlai            # a framework for sharing, training and testing dialogue models, from open-domain chitchat, to task-oriented dialogue, to visual question answering
KevinMusgrave/pytorch-metric-learning

# inference related
+ https://github.com/Tencent/ncnn
    + ncnn is a high-performance neural network inference framework optimized for the mobile platform
    + Supports GPU acceleration via the next-generation low-overhead vulkan api
    + Extensible model design, supports 8bit quantization and half-precision floating point storage
    + can import caffe/pytorch/mxnet/onnx/darknet/keras/tensorflow(mlir) models
+ https://github.com/Tencent/TNN
    + A high-performance, lightweight neural network inference framework open sourced by Tencent Youtu Lab.
    + It also has many outstanding advantages such as cross-platform, high performance, model compression, and code tailoring.
#}
