include:
  - desktop.manjaro.python.development
  - desktop.manjaro.python.scientific
  - desktop.manjaro.python.machinelearning
  - desktop.manjaro.python.jupyter

desktop_manjaro_python_init:
  test.nop:
    - require:
      - sls: desktop.manjaro.python.development
      - sls: desktop.manjaro.python.scientific
      - sls: desktop.manjaro.python.machinelearning
      - sls: desktop.manjaro.python.jupyter
