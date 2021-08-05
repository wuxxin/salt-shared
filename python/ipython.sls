include:
  - python
  - python.jinja2

interactive-python:
  pkg.installed:
    - pkgs:
      - python3-ipdb  {# python debugger, with IPython features #}
      - python3-jedi  {# autocompletion tool for Python #}
      - ipython3      {# Enhanced interactive Python shell #}
      - bpython3      {# fancy terminal interface to the Python interpreter #}
