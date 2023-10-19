#  Jupyter Ecosystem for Scientific Python and Hardware accelerated Machinelearning

PipX based Systemd User Service of Jupyter Server \& Chromium as Desktop Web-App for the Jupyter Client.

### Features

+ sufficiently secure local jupyter setup

+ machine wide packages
  + hardware support for **amd rocm** gpu's
    + pytorch-rocm, torchvision-rocm, tensorflow-rocm, jax-rocm, deepspeed
  + python packages installed **as system packages**,
  + python packages **build from aur** installed **as system packages**

+ **pipx** and systemd user unit is used for the **jupyterlab server environment** encapsulation
  + bundled set of jupyterlab extensions
  + easy updateable

+ re/creation of **jupyter kernel** environments from pillar

+ see defaults.jinja for system/aur package list


This way all system specific hardware related base libraries and python entrypoints
are systemwide installed, and all jupyter related is bundled in a pipx application,
systemd user units calling this pipx app as a jupyer server,
and a custom chromium as webapp config launch is used for the gui


### Usage

- configure pillar:
```yaml
jupyter:
  service:
    # create a token with "openssl rand -hex 24"
    token: {{ secrets.jupyter_notebooks_token }}
    notebook_dir: /home/user/code
  kernels:
    lab:
      packages:
        # transformers - pretrained models to perform text, vision, and audio tasks
        - python-transformers
        # fastai - training fast and accurate neural nets using modern best practices
        - fastai
```

- start jupyter service: `sytemctl --user start jupyter-core`
- start chromium client: in gnome shell: Jupyter Lab

### Notes

#### Issue: matplotlib.pyplot.xkcd not finding humor sans font
  + **Resolution**: refresh your system's font cache and to delete Maplotlib's font cache.
```sh
sudo fc-cache -f -v
cd ~/.cache/matplotlib; rm fontlist*.json
```


#### other lookworthy Packages

- inference
  + https://github.com/Tencent/ncnn
    + ncnn is a high-performance neural network inference framework optimized for the mobile platform
    + Supports GPU acceleration via the next-generation low-overhead vulkan api
    + Extensible model design, supports 8bit quantization and half-precision floating point storage
    + can import caffe/pytorch/mxnet/onnx/darknet/keras/tensorflow(mlir) models
  + https://github.com/Tencent/TNN
    + A high-performance, lightweight neural network inference framework open sourced by Tencent Youtu Lab.
    + It also has many outstanding advantages such as cross-platform, high performance, model compression, and code tailoring.

- scientific scientific_python_aur
  - python-panel
    - panel - high-level app and dashboarding solution
  - python-holoviews
    - holoviews - With Holoviews, your data visualizes itself
  - python-numba
    - numba - NumPy aware dynamic Python compiler using LLVM

- machinelearning ml_pytorch_extra_aur
  - python-optuna
    - optuna - automatic hyperparameter optimization software framework
  - monailabel
    - monailabel - intelligent open source image labeling and learning tool
  - python-kornia
    - kornia - classical computer vision integrated into deep learning models

- machinelearning ml_sklearn_aur
  - python-sklearn-pandas
    - sklearn-pandas - bridge between Scikit-Learn's methods and pandas-style Data Frames

- machine learning
  + streamlit.io
    + Streamlit turns data scripts into shareable web apps in minutes
  + gradio (older, people migrating to streamlit)
    + Create UIs for your machine learning model in Python in 3 minutes
  + jina
    + Build cross-modal and multimodal applications on the cloud
  + python-wandb
    + Weights and Biases - organize and analyze machine learning experiments

- jupyter
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

- lsp
  + python-lsp-mypy
  + python-lsp-isort

- sklearn
  + auto-sklearn

- torch
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
