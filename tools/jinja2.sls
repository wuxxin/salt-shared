{% from 'python/lib.sls' import pip3_install %}
include:
  - python

{# conversion/processor #}
{# CLI interface to Jinja2, reads yaml,xml,toml #}
jinja2-cli-req:
  pkg.installed:
    - pkgs:
      - python3-xmltodict
      - python3-toml
      - python3-yaml

{# get jinja from pypi, because < 2.11 (focal has 2.10.1) is broken for saltstack #}
jinja2-req:
  pkg.installed:
    - name: python3-markupsafe
{{ pip3_install('Jinja2>=2.11', require= 'pkg: jinja2-req') }}
{{ pip3_install('jinja2-cli[yaml,toml,xml]', require= ['pip: jinja2', 'pkg: jinja2-cli-req']) }}
