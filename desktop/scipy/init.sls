include:
  - python.dev

scipy:
  pkg.installed:
    - pkgs:
      - python3-numpy
      - python3-scipy
      - python3-matplotlib
      - python3-pandas
      - python3-sympy
      - python3-nose
      - python3-skimage
    - require:
      - sls: python
      - sls: python.ipython
