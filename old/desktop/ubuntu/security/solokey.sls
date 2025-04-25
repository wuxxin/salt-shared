{% from 'code/python/lib.sls' import pipx_install, pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home, user_desktop with context %}

include:
  - code.python.dev

{# solo - Python library for Solo keys https://pypi.org/project/solo-python #}
{# install as pipx user package, so its isolated from others #}
{{ pipx_install('solo-python', require=['sls: code.python.dev',], user=user) }}
