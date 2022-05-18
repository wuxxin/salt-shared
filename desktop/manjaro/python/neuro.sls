{# neurophysiological data #}
{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - desktop.manjaro.python.scientific

{% load_yaml as neurophysiological %}
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
