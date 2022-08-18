# Scientific Python using the Jupyter ecosystem

+ most python packages are installed **as system packages**
+ some system packages are **build from aur**
+ some python packages are only local in **user environment**
+ some python packages are only specific to **jupyter kernels**

## notes

### FAQ
+ ISSUE: matplotlib.pyplot.xkcd not finding humor sans font
  + RESOLUTION: refresh your system's font cache and to delete Maplotlib's font cache.
```sh
sudo fc-cache -f -v
cd ~/.cache/matplotlib; rm fontlist*.json
```

### currently disabled packages
```
## machinelearning ml_tools_aur
# sentencepiece - unsupervised text tokenizer and detokenizer
- python-sentencepiece-git

## machinelearning ml_pytorch_extra_aur
# kornia - classical computer vision integrated into deep learning models
- python-kornia

## machinelearning ml_sklearn_aur
{% load_yaml as pkgs %}
      ## sklearn
      # sklearn-pandas - bridge between Scikit-Learn's methods and pandas-style Data Frames
      - python-sklearn-pandas
{% endload %}
{{ pamac_install('ml_sklearn_aur', pkgs, require='pkg: ml_sklearn') }}
```

### additional packages
#### jupyter
+ python-pyarrow - Columnar in-memory analytics layer for big data
+ itables - Pandas DataFrames and Series as interactive datatables
+ finos/perspective - interactive analytics and data visualization for large and/or streaming datasets
+ elyra-pipeline-editor-extension

#### lsp
+ python-lsp-mypy
+ python-lsp-isort

#### sklearn
+ auto-sklearn

#### torch and others
+ jina
  + Build cross-modal and multimodal applications on the cloud
+ https://github.com/iterative/mlem
  + machine learning model deployment. It saves ML models in a standard format
+ python-wandb
  + Weights and Biases - organize and analyze machine learning experiments
+ python-timm
  + PyTorch Image Models
+ captum
  + Model interpretability and understanding for PyTorch
+ pytorchvideo
  + a deeplearning library with a focus on video understanding work
+ detectron2
  + Facebook AI Research's next generation library that provides state-of-the-art detection and segmentation algorithms
+ torch-geometric
  + PyTorch Geometric (PyG) is a geometric deep learning extension library for PyTorch
+ monai
  + Medical Open Network for AI for pytorch
+ flair
  + A very simple framework for state-of-the-art NLP. Developed by Humboldt University of Berlin and friends
+ allennlp
  + A natural language processing platform for building state-of-the-art models
+ vissl
  + A computer VIsion library for state-of-the-art Self-Supervised Learning research with PyTorch
+ pfrl
  + a deep reinforcement learning library that implements various state-of-the-art deep reinforcement algorithms
+ parlai
  + a framework for sharing, training and testing dialogue models, from open-domain chitchat, to task-oriented dialogue, to visual question answering
+ KevinMusgrave/pytorch-metric-learning

### inference
+ https://github.com/Tencent/ncnn
  + ncnn is a high-performance neural network inference framework optimized for the mobile platform
  + Supports GPU acceleration via the next-generation low-overhead vulkan api
  + Extensible model design, supports 8bit quantization and half-precision floating point storage
  + can import caffe/pytorch/mxnet/onnx/darknet/keras/tensorflow(mlir) models
+ https://github.com/Tencent/TNN
  + A high-performance, lightweight neural network inference framework open sourced by Tencent Youtu Lab.
  + It also has many outstanding advantages such as cross-platform, high performance, model compression, and code tailoring.
