include:
  - python

# jinja2-cli - CLI interface to Jinja2, including yaml,xml,toml support

{% if grains['os'] == 'Ubuntu' %}

python-jinja-req:
  pkg.installed:
    - pkgs:
      - python3-markupsafe
      - python3-xmltodict
      - python3-toml
      - python3-yaml

{{ pip_install('jinja2-cli[yaml,toml,xml]', require= ['pip: Jinja2>=2.11', 'pkg: python-jinja-req']) }}


{% elif grains['os'] == 'Manjaro' %}
  {% from 'python/lib.sls' import pipx_install %}
  {% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{{ pipx_install('jinja2-cli[yaml,toml,xml]', user=user) }}

{% endif  %}
