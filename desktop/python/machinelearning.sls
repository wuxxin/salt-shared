{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python.jupyter

{# machine learning frameworks (sklearn,tensorflow,pytorch) and supporting libraries #}
{% load_yaml as machinelearning %}
# ### generic ###
- statsmodels
# statsmodels: estimation of many different statistical models, conducting statistical tests, and statistical data exploration
- optuna
# optuna: hyperparameter optimization framework to automate hyperparameter search

# ### sklearn ###
- sklearn
- sklearn-pandas
- auto-sklearn

# ### tensorflow ###
- tensorflow
- tensorflow_hub
- tensorboard
- jupyterlab_tensorboard

# ### pytorch ###
- torch
- torchvision
- torchaudio
- torchtext
- torchinfo
# torchinfo: provides information complementary to print(your_model)
- skorch
# skorch: scikit-learn compatible neural network library that wraps PyTorch
- pytorch-lightning
# pytorch-lightning: lightweight PyTorch wrapper for high-performance AI research
- pytorchvideo
# pytorchvideo: a deeplearning library with a focus on video understanding work
- kornia
# kornia: classical computer vision integrated into deep learning models
- fastai

{% endload %}

{{ pipx_inject('jupyterlab', machinelearning,
    require='sls: desktop.python.jupyter', user=user) }}

{#
detectron2        # Facebook AI Research's next generation library that provides state-of-the-art detection and segmentation algorithms
torch-geometric   # PyTorch Geometric (PyG) is a geometric deep learning extension library for PyTorch
monai             # Medical Open Network for AI for pytorch
flair             # A very simple framework for state-of-the-art NLP. Developed by Humboldt University of Berlin and friends
allennlp          # A natural language processing platform for building state-of-the-art models
vissl             # A computer VIsion library for state-of-the-art Self-Supervised Learning research with PyTorch

albumentations    # a library for image augmentation to create new training samples from the existing data
pfrl              # a deep reinforcement learning library that implements various state-of-the-art deep reinforcement algorithms
parlai            # a framework for sharing, training and testing dialogue models, from open-domain chitchat, to task-oriented dialogue, to visual question answering
https://github.com/KevinMusgrave/pytorch-metric-learning
# general
transformers      # State-of-the-art Natural Language Processing for Jax, PyTorch and TensorFlow
#}
