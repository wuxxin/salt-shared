{% from "python/defaults.jinja" import settings with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install, pipx_inject %}

include:
  - python.dev

{# python code formating/linting/auditing tools #}
python_desktop:
  pkg.installed:
    - pkgs: {{ settings.python_desktop[grains['os_family']|lower] }}

{# install the following as pipx user package, so they are isolated from others #}
{% for i in settings.pipx_desktop[grains['os_family']] %}
{{ pipx_install(i, user=user) }}
{% endfor %}
