{% from 'python/lib.sls' import pip3_install %}
include:
  - python

{# get jinja from pypi, because > 2.9 < 2.11 is broken for saltstack #}
jinja2-req:
  pkg.installed:
    - name: python3-markupsafe

{{ pip3_install('Jinja2>=2.11', require= 'pkg: jinja2-req') }}

{# CLI interface to Jinja2, including yaml,xml,toml support #}
jinja2-cli-req:
  pkg.installed:
    - pkgs:
      - python3-xmltodict
      - python3-toml
      - python3-yaml

{{ pip3_install('jinja2-cli[yaml,toml,xml]', require= ['pip: Jinja2>=2.11', 'pkg: jinja2-cli-req']) }}
