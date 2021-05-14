{% from 'python/lib.sls' import pipx_install, pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - python.dev

{# scientific python composed of
scipy, numpy, matplotlib, pandas, sympy, ipython,
jupyter, jupyterlab,
sklearn, skimage, panel, bokeh, plotly, altair
# 'imageio', 'pil', 'sphinx', 'numpydoc', 'pytest', 'nose', 'joblib', 'psutil',
# panel needs bokeh param(0) pyviz_comms markdown pyct testpath
# recommends holoviews notebook matplotlib pillow plotly
# needs testpath<4 which conflicts with other system pacakges
#}

{{ pipx_install('scipy', require='sls:python.dev', user=user) }}
{{ pipx_inject('scipy', [
  'numpy', 'matplotlib', 'pandas', 'sympy', 'ipython',
  'skimage', 'sklearn', 'sklearn-pandas', 'auto-sklearn',
  'plotly', 'panel', 'bokeh', 'altair',
  ], user=user) }}
