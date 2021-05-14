{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - python.user.scipy

{{ pipx_inject('scipy', ['neurodsp',],
  require="sls:python.user.scipy", user=user) }}
