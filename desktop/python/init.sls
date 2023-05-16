include:
  - desktop.python.development
  - desktop.python.scientific
  - desktop.python.machinelearning
  - desktop.python.jupyter

desktop_python_init:
  test.nop:
    - require:
      - sls: desktop.python.development
      - sls: desktop.python.scientific
      - sls: desktop.python.machinelearning
      - sls: desktop.python.jupyter
