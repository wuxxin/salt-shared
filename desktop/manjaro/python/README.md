#  Jupyter Ecosystem for Scientific Python and Hardware accelerated Machinelearning

systemd user jupyter server, desktop chromium web-app as jupyter client.

+ hardware support for **amd rocm** gpu's in pytorch, tensorflow, jax
+ some python packages are installed **as system packages**
+ some system python packages are **build from aur**
+ **pipx** is used for the **jupyterlab server environment**
+ default for **jupyter kernels** is to use system site packages

## Notes

### Issue: matplotlib.pyplot.xkcd not finding humor sans font
  + **Resolution**: refresh your system's font cache and to delete Maplotlib's font cache.
```sh
sudo fc-cache -f -v
cd ~/.cache/matplotlib; rm fontlist*.json
```

### wanted, but currently not buildable packages

#### scientific scientific_python_aur
```
# panel - high-level app and dashboarding solution
- python-panel
# holoviews - With Holoviews, your data visualizes itself
- python-holoviews
# numba - NumPy aware dynamic Python compiler using LLVM
- python-numba
```

#### machinelearning ml_tools_aur
```
# sentencepiece - unsupervised text tokenizer and detokenizer
- python-sentencepiece-git
```

#### machinelearning ml_pytorch_extra_aur
```
# monailabel - intelligent open source image labeling and learning tool
- monailabel
# kornia - classical computer vision integrated into deep learning models
- python-kornia
```

#### machinelearning ml_sklearn_aur
```
# sklearn-pandas - bridge between Scikit-Learn's methods and pandas-style Data Frames
- python-sklearn-pandas
```

### additional untried and unevaluated packages found

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
+ jupyterlab-kernelspy
  + inspecting messages to/from a kernel
+ jupyterlab-friendly-traceback
  + A JupyterLab extension for friendly traceback
+ jupyter_innotater
  + Annotate data including image bounding boxes inline
+ jupyterlab_autoscrollcelloutput
+ jupyterlab-autosave-on-focus-change
+ jupyterlab_kernel_usage
+ ipylab
+ jupyterlab_tensorboard
+ jupyterlab_execute_time
+ jupyterlab_notify
+ jupyterlab-notifications

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
