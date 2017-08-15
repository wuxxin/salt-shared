include:
  - python.dev
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
      - sls: python.ipython
      - pkgrepo: neurodebian_ppa
