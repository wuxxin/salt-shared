{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python.machinelearning

{# working with neurophysiological data #}
{% load_yaml as neurophysiological %}
- pyvista
# pyvista: 3D plotting and mesh analysis interface for the Visualization Toolkit (VTK)
- opencv-python
# opencv-python: Pre-built CPU-only OpenCV Open Source Computer Vision Library
- pylsl
# pylsl: lab streaming layer
- neurodsp
# neurodsp: Neuro Digital Signal Processing Toolbox
- nilearn
# nilearn: Statistics for NeuroImaging in Python
- mne
# mne: exploring, visualizing, and analyzing human neurophysiological data
- brainflow
# brainflow: obtain, parse and analyze EEG, EMG, ECG and other kinds of data from biosensors
{% endload %}

{{ pipx_inject('jupyterlab', neurophysiological,
    require="sls: desktop.python.machinelearning", user=user) }}
