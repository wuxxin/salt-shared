{% from 'python/lib.sls' import pip3_install %}
include:
  - python.dev
  - python.jinja2
  - python.ipython

{# scientific python composed of
  numpy , scipy, matplotlib, pandas, sympy, sklearn, skimage, 
  panel, bokeh, plotly #}
      
scipy-image:
  pkg.installed:
    - pkgs:
      - python3-imageio
      - python3-pil

scipy-doc:
  pkg.installed:
    - pkgs:
      - python3-sphinx
      - python3-numpydoc

scipy-test:
  pkg.installed:
    - pkgs:
      - python3-pytest
      - python3-nose
      - python3-joblib
      - python3-psutil
      
scipy-tools:
  pkg.installed:
    - pkgs:
      - python3-dateutil
      - python3-packaging
      - python3-six
      - python3-yaml
      - python3-tornado
      - python3-markdown
      - python3-requests
    - require:
      - sls: python.jinja2

scipy:
  pkg.installed:
    - pkgs:
      - python3-numpy
      - python3-scipy
      - python3-matplotlib
      - python3-pandas
      - python3-sympy
      - python3-skimage
      - python3-sklearn
      - python3-sklearn-pandas
      - python3-plotly
    - require:
      - sls: python.dev
      - sls: python.ipython
      - pkg: scipy-image
      - pkg: scipy-doc
      - pkg: scipy-test

{{ pip3_install('pystan', require='pkg: scipy') }}
{{ pip3_install('bokeh', require='pkg: scipy') }}
# panel needs bokeh param(0) pyviz_comms markdown pyct testpath
# recommends holoviews notebook matplotlib pillow plotly
# needs testpath<4 which conflicts with other system pacakges
#  pip3_install('panel', require='pkg: scipy')
