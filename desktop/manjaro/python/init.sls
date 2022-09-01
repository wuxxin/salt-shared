{% from 'desktop/user/lib.sls' import user with context %}
{% from "desktop/manjaro/python/defaults.jinja" import settings with context %}
{% from 'desktop/manjaro/python/lib.sls' import jupyter_service, create_python_kernel, register_python_kernel %}

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

# install all configured kernels, and register for jupyter
{% for key, value in settings.kernel.items() %}
{{ create_python_kernel(user=user, name=key, pkgs=value.packages|d([]),
    system_packages=value.system_packages|d(true),
    require='test: desktop_manjaro_python_init') }}
{% endfor %}

# create a systemd user service for starting jupyter lab in background without gui
# and a desktop entry chromium app to start the gui app of jupyterlab
{% for key, value in settings.service.items() %}
  {% set chromium_args=
        settings.default.chromium.args+ value.chromium.args|d([]) if
            value.default_chromium|d(true) else value.chromium.args|d([]) %}
  {% set pkgs= settings.default.service.packages+ value.packages|d([])
        if value.default_packages|d(false) else value.packages|d([]) %}
{{ jupyter_service(
    user=user,
    notebook_dir=value.notebook_dir,
    port=value.port,
    token=value.token,
    pkgs=pkgs,
    chromium_args= chromium_args,
    chromium_extensions= chromium_extensions,
    require='test: desktop_manjaro_python_init') }}
{% endfor %}

# register all configured kernels for jupyter
{% for key, value in settings.kernel.items() %}
{{ register_python_kernel(user=user, name=key, require='pip: python_kernel_'~ key) }}
{% endfor %}
