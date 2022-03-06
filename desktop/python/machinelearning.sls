include:
  - desktop.python.jupyter

{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{% set torch_version='1.10.2' %}
{% set torch_flavor=pillar['torch:flavor']|d('cpu') %}

{% load_yaml as torch %}
cpu:
  pkgs:
  - torch=={{ torch_version }}+cpu
  - torchvision==0.11.3+cpu
  - torchaudio==0.10.2+cpu
  - torchtext
  links: https://download.pytorch.org/whl/cpu/torch_stable.html
rocm:
  pkgs:
  - torch
  - torchvision==0.11.3
  - torchaudio
  - torchtext
  links: https://download.pytorch.org/whl/rocm4.2/torch_stable.html
cuda10:
  pkgs:
  - torch
  - torchvision
  - torchaudio
  - torchtext
  links:
cuda11:
  pkgs:
  - torch=={{ torch_version }}+cu113
  - torchvision==0.11.3+cu113
  - torchaudio==0.10.2+cu113
  - torchtext
  links: https://download.pytorch.org/whl/cu113/torch_stable.html
{% endload %}


{# machine learning frameworks (sklearn,tensorflow,pytorch) and supporting libraries #}
{% load_yaml as machinelearning %}
# ### sklearn ###
- sklearn
- sklearn-pandas
- auto-sklearn

# ### tensorflow ###
- tensorflow
- tensorflow_hub
- tensorboard

# ### pytorch ###
# pytorch consists of torch, torchvision, torchaudio, torchtext
{% for pkg in torch[torch_flavor]['pkgs'] %}
- {{ pkg }}
{% endfor %}

# torchinfo: provides information complementary to print(your_model)
- torchinfo
# pytorchvideo: a deeplearning library with a focus on video understanding work
- pytorchvideo
# kornia: classical computer vision integrated into deep learning models
- kornia
# fastai: simplifies training fast and accurate neural nets using modern best practices
- fastai
# skorch: scikit-learn compatible neural network library that wraps PyTorch
- skorch
# pytorch-lightning: lightweight PyTorch wrapper for high-performance AI research
- pytorch-lightning

# ### generic ###
# statsmodels - estimation of many different statistical models, conducting statistical tests, and statistical data exploration
- statsmodels
# optuna - hyperparameter optimization framework to automate hyperparameter search
- optuna
# transformers - State-of-the-art Natural Language Processing for Jax, PyTorch and TensorFlow
transformers
{% endload %}

{% if torch[torch_flavor]['links'] %}

{{ pipx_inject('jupyterlab', machinelearning,
    require='sls: desktop.python.jupyter', user=user,
    pip_args='"-f '~ torch[torch_flavor]['links']~ '"' ) }}

{% else %}

{{ pipx_inject('jupyterlab', machinelearning,
    require='sls: desktop.python.jupyter', user=user) }}

{% endif %}

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
#}
