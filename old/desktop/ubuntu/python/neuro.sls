{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.ubuntu.python.machinelearning

{# working with neurophysiological data #}
{% load_yaml as neurophysiological %}
# pyvista: 3D plotting and mesh analysis interface for the Visualization Toolkit (VTK)
- pyvista
# opencv-python: Pre-built CPU-only OpenCV Open Source Computer Vision Library
- opencv-python
# pylsl: lab streaming layer
- pylsl
# neurodsp: Neuro Digital Signal Processing Toolbox
- neurodsp
# nilearn: Statistics for NeuroImaging in Python
- nilearn
# mne: exploring, visualizing, and analyzing human neurophysiological data
- mne
# brainflow: obtain, parse and analyze EEG, EMG, ECG and other kinds of data from biosensors
- brainflow
{% endload %}

{{ pipx_inject('jupyterlab', neurophysiological,
    require="sls: desktop.ubuntu.python.machinelearning", user=user) }}
