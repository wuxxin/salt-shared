{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install %}

include:
  - code.python.dev

{# install argostranslate as pipx user package, so its isolated from others #}
{{ pipx_install('argostranslate', user=user) }}
