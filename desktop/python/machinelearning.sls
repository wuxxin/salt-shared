{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python.jupyter


{# machine learning #}
{{ pipx_inject('jupyterlab', [
  'sklearn', 'sklearn-pandas', 'auto-sklearn',
  'tensorflow', 'tensorflow_hub', 'tensorboard', 'jupyterlab_tensorboard',
  'torch', 'torchvision', 'torchaudio', 'torchtext',
  'fastai',
  'statsmodels',
  ], require='sls: desktop.python.jupyter', user=user) }}

{#
# machine learning frameworks
sklearn*          #
tensorflow*       #
torch*            #

# torch libraries
torchvision       #
torchaudio        #
torchtext         #

skorch            # skorch is designed to maximize interoperability between sklearn and pytorch
kornia            # a differentiable library that allows classical computer vision to be integrated into deep learning models
albumentations    # a library for image augmentation to create new training samples from the existing data
detectron2        # Facebook AI Research's next generation library that provides state-of-the-art detection and segmentation algorithms
pfrl              # a deep reinforcement learning library that implements various state-of-the-art deep reinforcement algorithms
parlai            # a framework for sharing, training and testing dialogue models, from open-domain chitchat, to task-oriented dialogue, to visual question answering
flair             # A very simple framework for state-of-the-art NLP. Developed by Humboldt University of Berlin and friends

# general
transformers      # State-of-the-art Natural Language Processing for Jax, PyTorch and TensorFlow
#}
