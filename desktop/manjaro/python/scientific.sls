{# scientific python #}
{% from 'desktop/user/lib.sls' import user with context %}
{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - desktop.manjaro.python.development
  - desktop.manjaro.python.hardware_optimized
  - nodejs

scientific_base:
  test.nop:
    - require:
      - sls: desktop.manjaro.python.development
      - sls: desktop.manjaro.python.hardware_optimized
      - sls: nodejs

# customized gui components
scientific_gui:
  pkg.installed:
    - pkgs:
      # chromium - used as browser app for juptyer GUI
      - chromium
{% load_yaml as pkgs %}
      # ttf-humor-sans - xkcd styled sans-serif typeface
      - ttf-humor-sans
{% endload %}
{{ pamac_install("scientific_gui_aur", pkgs) }}


scientific_python:
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
      # - pyside2
      # pyside6 -	Enables the use of Qt6 APIs in Python applications
      - pyside6
      # Statistical data visualization
      - python-seaborn
      # python-opencv - Open Source Computer Vision Library
      - python-opencv
    - require:
      - test: scientific_base
      - pkg: scientific_gui
      - test: scientific_gui_aur

{% load_yaml as pkgs %}
      ## scientific python
      # pooch - fetching and caching data files
      - python-pooch
      # scikit-image - Image processing routines for SciPy
      - python-scikit-image
      # bokeh - Interactive Web Plotting
      - python-bokeh
      # plotly - interactive graphing library
      - python-plotly
      # altair - Declarative statistical visualization library
      - python-altair
      # panel - high-level app and dashboarding solution
      - python-panel
      # holoviews - With Holoviews, your data visualizes itself
      - python-holoviews
{% endload %}
{{ pamac_install('scientific_python_aur', pkgs,
    require='pkg: scientific_python') }}
