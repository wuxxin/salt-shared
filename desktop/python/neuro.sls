{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python.machinelearning

{# working with neurophysiological data #}

{# brainflow: obtain, parse and analyze
              EEG, EMG, ECG and other kinds of data from biosensors #}
{# pylsl:     lab streaming layer #}
{# neurodsp:  Neuro Digital Signal Processing Toolbox #}
{# mne:       exploring, visualizing, and analyzing human neurophysiological data:
              MEG, EEG, sEEG, ECoG, NIRS, and more #}
{# opencv-python:
              Pre-built CPU-only OpenCV Open Source Computer Vision Library
              with several hundreds of computer vision algorithms #}
{# pyvista:   3D plotting and mesh analysis through a streamlined interface for
              the Visualization Toolkit (VTK) #}
{# nilearn:   Statistics for NeuroImaging in Python #}

{{ pipx_inject('jupyterlab', [
    'pyvista',
    'pylsl',
    'nilearn',
    'mne',
    'neurodsp',
    'brainflow',
    'opencv-python',
  ], require="sls: desktop.python.machinelearning", user=user) }}
