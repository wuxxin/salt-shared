{# scientific python #}
{% from 'code/python/lib.sls' import pipx_install %}
{% from 'desktop/user/lib.sls' import user with context %}
{% from 'arch/lib.sls' import aur_install with context %}

include:
  - desktop.python.development
  - code.nodejs

scientific_base:
  test.nop:
    - require:
      - sls: desktop.python.development
      - sls: code.nodejs

scientific_optimized:
  pkg.installed:
    - pkgs:
      # blas-openblas - An optimized BLAS library based on GotoBLAS2 1.13 BSD (Provides BLAS/CBLAS/LAPACK/LAPACKE system-wide)
      - blas-openblas
      # blas64-openblas - An optimized BLAS library based on GotoBLAS2 1.13 BSD (64-bit integers, provides BLAS/CBLAS/LAPACK/LAPACKE system-wide)
      - blas64-openblas

# gui components
scientific_gui:
  pkg.installed:
    - pkgs:
      # chromium - used as browser app for juptyer GUI
      - chromium
{% load_yaml as pkgs %}
      # ttf-humor-sans - xkcd styled sans-serif typeface
      # - ttf-humor-sans
      # python-playwright - Python library to automate Chromium, Firefox and WebKit browsers with a single API
      - python-playwright
{% endload %}
{{ aur_install("scientific_gui_aur", pkgs) }}


scientific_python:
  pkg.installed:
    - pkgs:
      ## scientific python
      - python-scipy
      # numpy - scientific computing
      - python-numpy
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
      # pillow - Python Imaging Library (PIL) fork
      - python-pillow
      # python-opencv - Open Source Computer Vision Library
      - python-opencv      
      # Statistical data visualization
      - python-seaborn
      # pyside6 - Enables the use of Qt6 APIs in Python applications
      - pyside6
    - require:
      - test: scientific_base
      - pkg: scientific_optimized
      - pkg: scientific_gui
      - test: scientific_gui_aur

{% load_yaml as pkgs %}
      ## scientific python
      # python-modin - Multicore Pandas Implementation - Speed up your Pandas workflows by changing a single line of code
      # - python-modin
      # scikit-image - Image processing routines for SciPy
      - python-scikit-image
      # bokeh - Interactive Web Plotting
      - python-bokeh
      # plotly - interactive graphing library
      - python-plotly
      # altair - Declarative statistical visualization library
      - python-altair
      # pooch - fetching and caching data files
      - python-pooch
{% endload %}
{{ aur_install('scientific_python_aur', pkgs,
    require='pkg: scientific_python') }}

# scientific_gui_pipx
# marimo - reactive Python notebook that's reproducible, git-friendly, and deployable as scripts or apps
{{ pipx_install('marimo', user=user) }}
