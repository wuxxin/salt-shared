{# scientific python #}
{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - desktop.manjaro.python.development
  - desktop.manjaro.python.hardware_optimized
  - nodejs

scientific_browser_app:
  pkg.installed:
    - pkgs:
      - chromium

scientific_python_base:
  pkg.installed:
    - pkgs:
      ## scientific python
      - python-scipy
      # pandas - data structures and data analysis
      - python-pandas
      - python-pandas-datareader
      # statsmodels - estimation of many different statistical models, conducting statistical tests, and statistical data exploration
      - python-statsmodels
      # xarray - N-D labeled arrays and datasets in Python
      - python-xarray

      # matplotlib - plotting library, making publication quality plots
      - python-matplotlib
      - python-matplotlib-inline
      # pyside2 - use of Qt5 APIs in Python applications
      - pyside2
      # Statistical data visualization
      - python-seaborn
      # python-opencv - Open Source Computer Vision Library
      - python-opencv

      ## jupyter
      - jupyterlab
      - python-jupyterlab_server
      # nbconvert - jupyter Notebook Conversion
      - jupyter-nbconvert
      # jupyterlab-widgets - extensions to use ipywidgets, needs nodejs and npm
      - jupyterlab-widgets

      ## language server
      - python-lsp-server
      - python-lsp-black
      - python-lsp-jsonrpc
      - bash-language-server
      - yaml-language-server
    - require:
      - sls: desktop.manjaro.python.hardware_optimized

{% load_yaml as pkgs %}
      ## scientific python
      # bokeh - Interactive Web Plotting
      - python-bokeh
      # scikit-image - Image processing routines for SciPy
      - python-scikit-image
      # pooch - fetching and caching data files
      - python-pooch
      # plotly - interactive graphing library
      - python-plotly
      # altair - Declarative statistical visualization library
      - python-altair
      # datashader - Quickly and accurately render even the largest data
      - python-datashader
      # panel - high-level app and dashboarding solution
      - python-panel
      # holoviews - With Holoviews, your data visualizes itself
      - python-holoviews
      # python-hvplot

      ## jupyter: widgets, extensions, converter, kernels
      # jupyterlab-lsp - Coding assistance for JupyterLab with Language Server Protocol
      - jupyterlab-lsp
      # jupyterlab_git - Git extension for JupyterLab
      - jupyterlab-extension-jupyterlab_git
      # jupyterlab-execute-time - display cell timings in Jupyter Lab
      - jupyterlab-execute-time
      # python-ipympl - Matplotlib Jupyter Extension
      - python-ipympl
      # jupyterlab-plotly - Jupyter Extension for Plotly.py
      - jupyterlab-plotly
      # pelican-jupyter - Pelican static webpage plugin for Jupyter Notebooks
      - python-pelican-jupyter
      # jupytext - Jupyter notebooks as diffable Markdown, Julia or Python
      - python-jupytext
      # py2nb - Convert python scripts to jupyter
      - python-py2nb
      # nbdime - Diff and merge of Jupyter Notebooks
      - python-nbdime
      # ipysheet - Spreadsheet in the jupyter notebook
      - python-ipysheet
      ### jupyter: kernels
      - xeus
      ### jupyter: language
      # jupyterlab-language-pack-de-de - German (Germany) language pack for JupyterLab
      - jupyterlab-language-pack-de-de

      ## language server: additional
      - dockerfile-language-server
      - python-pylsp-rope
{% endload %}
{{ pamac_install('scientific_python_aur', pkgs,
    require='pkg: scientific_python_base') }}

scientific_python:
  test.nop:
    - require:
      - pkg: scientific_python_base
      - test: scientific_python_aur
