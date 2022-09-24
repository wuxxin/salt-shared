{% from 'desktop/user/lib.sls' import user with context %}
{% from "desktop/manjaro/python/defaults.jinja" import settings with context %}
{% from 'desktop/manjaro/python/lib.sls' import jupyter_service, create_python_kernel, register_python_kernel %}

include:
  - desktop.manjaro.python.scientific
  - desktop.manjaro.python.machinelearning

jupyter_base:
  test.nop:
    - require:
      - sls: desktop.manjaro.python.scientific
      - sls: desktop.manjaro.python.machinelearning

# create a pipx jupyterlab with a systemd user service and a desktop chromium app entry
{% for key, value in settings.service.items() %}
  {% set chromium_args=
        settings.default.chromium.args+ value.chromium.args|d([]) if
            value.default_chromium|d(true) else value.chromium.args|d([]) %}
  {% set pkgs= settings.default.service.packages+ value.packages|d([])
        if value.default_packages|d(false) else value.packages|d([]) %}
  {% set apps= settings.default.service.apps+ value.apps|d([])
        if value.default_apps|d(false) else value.apps|d([]) %}
{{ jupyter_service(
    user=user,
    name=key,
    notebook_dir=value.notebook_dir,
    port=value.port,
    token=value.token,
    pkgs=pkgs,
    apps=apps,
    chromium_args= chromium_args,
    chromium_extensions= chromium_extensions,
    require='test: jupyter_base') }}
{% endfor %}


# install all configured kernels
{% for key, value in settings.kernel.items() %}
{{ create_python_kernel(
    user=user,
    name=key,
    pkgs=value.packages|d([]),
    system_packages=value.system_packages|d(true),
    require='test: jupyter_base') }}
{% endfor %}

# register all configured kernels for jupyter
{% for key, value in settings.kernel.items() %}
{{ register_python_kernel(user=user, name=key, require='pip: python_kernel_'~ key) }}
{% endfor %}
