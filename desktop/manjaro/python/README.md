# Scientific Python using the Jupyter ecosystem

most python packages are installed as system packages,
some system packages are build from aur,
some python packages are only local in user environment or specific jupyter kernels

## notes

### currently disabled packages
```
## machinelearning ml_tensorflow
ml_tensorflow:
  test.nop:
    - require:
      - test: scientific_python
      - test: ml_tools_aur
      - sls: hardware.amd.rocm.tensorflow

## machinelearning ml_tools_aur
# sentencepiece - unsupervised text tokenizer and detokenizer
- python-sentencepiece-git

## machinelearning ml_pytorch_extra_aur
# kornia - classical computer vision integrated into deep learning models
- python-kornia

## machinelearning ml_sklearn_aur
{% load_yaml as pkgs %}
      ## sklearn
      # sklearn-pandas - bridge between Scikit-Learn's machine learning methods and pandas-style Data Frames
      - python-sklearn-pandas
{% endload %}
{{ pamac_install('ml_sklearn_aur', pkgs, require='pkg: ml_sklearn') }}

## machinelearning ml_pytorch_extra_aur
# fastai - simplifies training fast and accurate neural nets using modern best practices
{{ pamac_patch_install_dir('python-fastcore',
    'salt://desktop/manjaro/python/python-fastcore',
    require= 'test: ml_pytorch_extra_aur') }}
{{ pamac_patch_install_dir('python-fastai2',
    'salt://desktop/manjaro/python/python-fastai2',
    require= 'test: python-fastcore') }}

```

### jupyter
+ python-pyarrow - Columnar in-memory analytics layer for big data
+ itables - Pandas DataFrames and Series as interactive datatables
+ finos/perspective - interactive analytics and data visualization component for large and/or streaming datasets
+ elyra-pipeline-editor-extension

### lsp
+ python-lsp-mypy
+ python-lsp-isort

### ml using torch and others
+ python-wandb      # Weights and Biases - organize and analyze machine learning experiments
+ python-timm       # PyTorch Image Models
+ captum            # Model interpretability and understanding for PyTorch

+ pytorchvideo      # a deeplearning library with a focus on video understanding work
+ detectron2        # Facebook AI Research's next generation library that provides state-of-the-art detection and segmentation algorithms
+ torch-geometric   # PyTorch Geometric (PyG) is a geometric deep learning extension library for PyTorch
+ monai             # Medical Open Network for AI for pytorch
+ flair             # A very simple framework for state-of-the-art NLP. Developed by Humboldt University of Berlin and friends
+ allennlp          # A natural language processing platform for building state-of-the-art models
+ vissl             # A computer VIsion library for state-of-the-art Self-Supervised Learning research with PyTorch
+ pfrl              # a deep reinforcement learning library that implements various state-of-the-art deep reinforcement algorithms
+ parlai            # a framework for sharing, training and testing dialogue models, from open-domain chitchat, to task-oriented dialogue, to visual question answering
+ KevinMusgrave/pytorch-metric-learning

### sklearn
+ auto-sklearn

### inference
+ https://github.com/Tencent/ncnn
    + ncnn is a high-performance neural network inference framework optimized for the mobile platform
    + Supports GPU acceleration via the next-generation low-overhead vulkan api
    + Extensible model design, supports 8bit quantization and half-precision floating point storage
    + can import caffe/pytorch/mxnet/onnx/darknet/keras/tensorflow(mlir) models
+ https://github.com/Tencent/TNN
    + A high-performance, lightweight neural network inference framework open sourced by Tencent Youtu Lab.
    + It also has many outstanding advantages such as cross-platform, high performance, model compression, and code tailoring.
#}
