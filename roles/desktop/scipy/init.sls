include:
  - python
  - python.ipython
  - .ppa

scipy:
  pkg.installed:
    - pkgs:
      - python-numpy
      - python-scipy
      - python-matplotlib
      - python-pandas
      - python-sympy
      - python-nose
      - python-skimage
    - require:
      - sls: python
      - pip: ipython
      - pip: jupyter
      - pkgrepo: neurodebian_ppa
