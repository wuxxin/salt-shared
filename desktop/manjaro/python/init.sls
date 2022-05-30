{% from 'python/lib.sls' import pipx_install %}
{% from 'desktop/user/lib.sls' import user with context %}
{% from 'desktop/manjaro/python/lib.sls' import jupyter_user_service, jupyter_user_kernel %}
{% from "desktop/manjaro/python/defaults.jinja" import settings with context %}

include:
  - desktop.manjaro.python.development
  - desktop.manjaro.python.scientific
  - desktop.manjaro.python.machinelearning

desktop_manjaro_python_init:
  test.nop:
    - require:
      - sls: desktop.manjaro.python.development
      - sls: desktop.manjaro.python.scientific
      - sls: desktop.manjaro.python.machinelearning

# install user packages for jupyter if configured
{% if settings.user.default_packages or settings.user.packages %}
user_python_env_jupyter_packages:
  pip.installed:
    - user: {{ user }}
    - pkgs: {{ settings.default.packages + settings.user.packages  }}
    - use_vt: true
{% endif %}

{#
# install all configured kernels for jupyter
{% for key, value in settings.kernel.items() %}
{{ jupyter_user_kernel(user=user, name=key, pkgs=value.packages,
    system_packages=value.system_packages|d(true),
    rebuild=value.rebuild|d(false),
    require='test: desktop_manjaro_python_init') }}
{% endfor %}
#}

{% for key, value in settings.service.items() %}
# create a systemd user service for starting jupyter lab in background without gui
# and a desktop entry chromium app to start the gui app of jupyterlab
{{ jupyter_user_service(user=user,
    notebook_dir=value.notebook_dir,
    port=value.port,
    require='test: desktop_manjaro_python_init') }}
{% endfor %}

# euporie - jupyter Text-User-Interface
{{ pipx_install('euporie', user=user) }}
