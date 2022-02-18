{% from "python/defaults.jinja" import settings with context %}
{% from 'python/lib.sls' import pip_install %}

include:
  - python

{% if grains['os'] == 'Ubuntu' %}
python-jinja-req:
  pkg.installed:
    - pkgs: {{ settings.jinja[grains['os_family']|lower] }}

{# get jinja from pypi, because > 2.9 < 2.11 is broken for saltstack #}
{{ pip_install('Jinja2>=2.11', require= 'pkg: python-jinja-req') }}
{# CLI interface to Jinja2, including yaml,xml,toml support #}
{{ pip_install('jinja2-cli[yaml,toml,xml]', require= ['pip: Jinja2>=2.11', 'pkg: python-jinja-req']) }}

{% else %}
python-jinja:
  pkg.installed:
    - pkgs: {{ settings.jinja[grains['os_family']|lower] }}

{{ pip_install('jinja2-cli[yaml,toml,xml]', require= ['pkg: python-jinja']) }}

{% endif  %}
