{% from 'python/lib.sls' import pip3_install %}

{# conversion/processor #}
{# CLI interface to Jinja2, reads yaml,xml,toml #}
jinja2-cli-req:
  pkg.installed:
    - pkgs:
      - python3-xmltodict
      - python3-toml
      - python3-yaml

{# get jinja from pypi if older than bionic #}
{%- if grains['osmajorrelease']|int < 18 %}
jinja2-req:
  pkg.installed:
    - name: python3-markupsafe
{{ pip3_install('jinja2', require= 'pkg: jinja2-req') }}
{{ pip3_install('jinja2-cli[yaml,toml,xml]', require= ['pip: jinja2', 'pkg: jinja2-cli-req']) }}

{%- else %}
jinja2:
  pkg.installed:
    - name: python3-jinja2
{{ pip3_install('jinja2-cli[yaml,toml,xml]', require= ['pkg: jinja2', 'pkg: jinja2-cli-req']) }}
{%- endif %}

