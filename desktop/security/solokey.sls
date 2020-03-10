include:
  - python.dev
  
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{# solo - Python library for Solo keys https://pypi.org/project/solo-python #}
{# install as pipx user package, so its isolated from others #}
solo:
  cmd.run:
    - name: pipx install solo-python
    - unless: pipx list | grep solo-python -q 
    - runas: {{ user }}
