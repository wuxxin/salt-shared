# Scientific Python using the Jupyter ecosystem

+ some python packages are installed **as system packages**
+ some system python packages are **build from aur**
+ some python packages are installed in the **jupyter server environment**
+ some python packages are installed in the **jupyter kernels**

## Notes

### Issue: matplotlib.pyplot.xkcd not finding humor sans font
  + **Resolution**: refresh your system's font cache and to delete Maplotlib's font cache.
```sh
sudo fc-cache -f -v
cd ~/.cache/matplotlib; rm fontlist*.json
```

### currently disabled packages

#### scientific scientific_python_aur

- python-numba
  - NumPy aware dynamic Python compiler using LLVM

#### machinelearning ml_tools_aur
- python-sentencepiece-git
  - unsupervised text tokenizer and detokenizer

#### machinelearning ml_pytorch_extra_aur

- python-kornia
  - classical computer vision integrated into deep learning models

#### machinelearning ml_sklearn_aur
- python-sklearn-pandas
  - bridge between Scikit-Learn's methods and pandas-style Data Frames


#### scientific jupyter server

- jupyterlab-kernelspy
  - inspecting messages to/from a kernel
- jupyterlab-friendly-traceback
  - A JupyterLab extension for friendly traceback
- jupyter_innotater
  - Annotate data including image bounding boxes inline
- jupyterlab_autoscrollcelloutput
- jupyterlab_kernel_usage
- ipylab
- jupyterlab_tensorboard
- jupyterlab_execute_time
- jupyterlab_notify
- jupyterlab-notifications

### additional packages

#### machine learning
+ gradio
  + Create UIs for your machine learning model in Python in 3 minutes
+ jina
  + Build cross-modal and multimodal applications on the cloud
+ python-wandb
  + Weights and Biases - organize and analyze machine learning experiments

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

#### torch
+ https://github.com/iterative/mlem
  + machine learning model deployment. It saves ML models in a standard format
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
