{% from 'desktop/user/lib.sls' import user with context %}
{% from "desktop/python/defaults.jinja" import settings with context %}
{% from 'desktop/python/lib.sls' import jupyter_service, jupyter_core, create_python_kernel, register_python_kernel %}

include:
  - desktop.python.scientific
  - desktop.python.machinelearning

jupyter_base:
  test:
    - nop
    - require:
      - sls: desktop.python.scientific
      - sls: desktop.python.machinelearning

{% set chromium_args= settings.default.chromium.args+ settings.service.chromium.args|d([])
      if settings.service.default_chromium|d(true)
      else settings.service.chromium.args|d([]) %}
{% set pkgs= settings.default.service.packages+ settings.service.packages|d([])
      if settings.service.default_packages|d(false)
      else settings.service.packages|d([]) %}
{% set apps= settings.default.service.apps+ settings.service.apps|d([])
      if settings.service.default_apps|d(false)
      else settings.service.apps|d([]) %}

# create a pipx jupyter package
{{ jupyter_core(user, pkgs, apps) }}

# create a systemd user service for jupyter-core and a desktop chromium app entry
{{ jupyter_service(
    user=user,
    notebook_dir=settings.service.notebook_dir,
    port=settings.service.port,
    token=settings.service.token,
    chromium_args= chromium_args,
    chromium_extensions= chromium_extensions,
    require='test: jupyter_base') }}

# install all configured kernels
{% for key, value in settings.kernels.items() %}
{{ create_python_kernel(
    user=user,
    name=key,
    pkgs=value.packages|d([]),
    system_packages=value.system_packages|d(true),
    require='test: jupyter_base') }}
{% endfor %}

# register all configured kernels for jupyter
{% for key, value in settings.kernels.items() %}
{{ register_python_kernel(user=user, name=key, require='pip: python_kernel_'~ key) }}
{% endfor %}
