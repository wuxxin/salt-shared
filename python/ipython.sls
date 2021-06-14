include:
  - python
  - python.jinja2

ipython:
  pkg.installed:
    - pkgs:
      - ipython3      {# Enhanced interactive Python shell #}
      - python3-ipdb  {# python debugger, with IPython features #}

bpython:
  pkg.installed:
      - python3-jedi  {# autocompletion tool for Python #}
      - bpython3      {# fancy interface to the Python interpreter #}
