{% from 'desktop/user/lib.sls' import user with context %}
{% from "desktop/manjaro/python/defaults.jinja" import settings with context %}
{% from 'desktop/manjaro/python/lib.sls' import jupyter_user_service, jupyter_user_kernel %}

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
  {% set pkgs= settings.default.packages+ settings.user.packages if
        settings.user.default_packages else settings.user.packages %}
user_python_env_jupyter_packages:
  pip.installed:
    - user: {{ user }}
    - pkgs: {{ pkgs }}
    - require:
      - test: desktop_manjaro_python_init
{% endif %}

# install all configured kernels for jupyter
{% for key, value in settings.kernel.items() %}
  {% set pkgs= settings.default.packages+ value.packages|d([]) if
        value.default_packages|d(true) else value.packages|d([]) %}
{{ jupyter_user_kernel(user=user, name=key, pkgs=pkgs,
    system_packages=value.system_packages|d(true),
    require='test: desktop_manjaro_python_init') }}
{% endfor %}

{% for key, value in settings.service.items() %}
# create a systemd user service for starting jupyter lab in background without gui
# and a desktop entry chromium app to start the gui app of jupyterlab
{{ jupyter_user_service(user=user,
    notebook_dir=value.notebook_dir,
    port=value.port, token=value.token,
    require='test: desktop_manjaro_python_init') }}
{% endfor %}
