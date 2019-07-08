{% from 'python/lib.sls' import pip3_install %}
include:
  - python.scientific

mne-utils:
  pkg.installed:
    - pkgs:
      - python3-pytest
      - python3-pytest-cov
      - python3-pytest-mock
      - python3-pytest-sugar
      - python3-pytest-timeout
      {# pytest-faulthandler #}
      - python3-nose
      - python3-flake8
      - flake8
      - pydocstyle
      - python3-pydocstyle
      - python3-sphinx
      - python3-imageio
      - python3-pil
      - python3-joblib
      - python3-psutil

mne-requisites:
  pkg.installed:
    - pkgs:  
      - qt5dxcb-plugin
      - python3-pyqt5
      - python3-sip
      - python3-nibabel
      - python3-h5py
      - python3-numexpr
      - python3-statsmodels
      - python3-xlrd
    
    - require:
      - sls: python.scientific
      - pkg: mne-utils

# vtki needs
#   numpy, matplotlib, pyqt5, imageio, 
#   vtk, ipywidgets, appdirs, pytest, pytest-cov,
#   codecov, pytest-qt, nbval
vtki:
  pkg.installed:
    - pkgs:
      - python3-vtk7
      - python3-ipywidgets
      - python3-appdirs
      - python3-pytest-cov
    - require:
      - pkg: mne-requisites
  {#
  codecov
  pytest-qt
  nbval
  #}

# mayavi needs apptools envisage numpy pyface pygments sphinx trais traitsui vtk
mayavi-requisites:
  pkg.installed:
    - pkgs:
      - python3-apptools
      - python3-pygments
      - python3-traits
      - python3-vtk7
      - xvfb
    - require:
      - pkg: mne-requisites
      - pkg: vtki

# envisage needs apptools, traits
{{ pip3_install('envisage', require=[
  'sls: python.scientific', 'pkg: mayavi-requisites']) }}

# pyface needs numpy, pygments, traits, nose, mock, traitsui, traits_enaml
{{ pip3_install('pyface', require=[
  'sls: python.scientific', 'pkg: mayavi-requisites']) }}

# traitsui needs pyface traits
{{ pip3_install('traitsui', require=[
  'sls: python.scientific', 'pkg: mayavi-requisites']) }}

# mayavi needs apptools envisage numpy pyface pygments sphinx trais traitsui vtk
#  QT_QPA_PLATFORM='offscreen' or run it in xvfb-run
{{ pip3_install('mayavi', require=[
  'sls: python.scientific', 'pkg: mayavi-requisites',
  'pip: traitsui', 'pip: pyface', 'pip: envisage']) }}

# pylsl (lab streaming layer)
{{ pip3_install('pylsl', require='sls: python.scientific') }}

# quantities needs numpy
{{ pip3_install('quantities', require='sls: python.scientific') }}

# neo needs numpy, quantities, nose
{{ pip3_install('neo', require=[
  'sls: python.scientific', 'pip: quantities', 'pkg: mne-requisites']) }}

# dipy needs cython, numpy, scippy, nibabel, h5py
{{ pip3_install('dipy', require=[
  'sls: python.scientific', 'pkg: mne-requisites']) }}

# python-picard needs numpy, matplotlib, numexpr, scipy
{{ pip3_install('python-picard', require=[
  'sls: python.scientific', 'pkg: mne-requisites']) }}

# nilearn needs numpy scipy scikit-learn, nibabel
{{ pip3_install('nilearn', require=[
  'sls: python.scientific', 'pkg: mne-requisites']) }}

# PySurfer needs numpy, scipy, matplotlib, nibabel, mayavi, imageio
{{ pip3_install('PySurfer[save_movie]', require=[
  'sls: python.scientific', 'pkg: mne-requisites', 'pip: mayavi']) }}

{{ pip3_install('mne', require=[
'sls: python.scientific', 'pkg: mne-requisites', 'pip: mayavi']) }}

