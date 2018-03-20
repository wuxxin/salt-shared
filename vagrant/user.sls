{% from "vagrant/defaults.jinja" import settings, dependencies with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{# include states needed for plugins #}
include:
  - vagrant
{%- for plugin in settings.plugins %}
{%- if plugin in dependencies and dependencies[plugin]['sls'] is defined %}
{%- for slsfile in dependencies[plugin]['sls'] %}
  - {{ slsfile }}
{%- endfor %}
{%- endif %}
{%- endfor %}
{%- if settings.virtualbox|d(false) and 
  salt['pillar.get']('desktop:proprietary:enabled', false) %}
  - desktop.emulation.virtualbox
{%- endif %}


{# install pkgs and require sls files needed for plugins #}
vagrant_plugin_deps:
  pkg.installed:
    - pkgs:
      - ruby-dev
{%- for plugin in settings.plugins %}
{%- if plugin in dependencies and dependencies[plugin]['pkgs'] is defined %}
{%- for pkg in dependencies[plugin]['pkgs'] %}
      - {{ pkg }}
{%- endfor %}
{%- endif %}
{%- endfor %}
    - require:
      - sls: vagrant
{%- for plugin in settings.plugins %}
{%- if plugin in dependencies and dependencies[plugin]['sls'] is defined %}
{%- for slsfile in dependencies[plugin]['sls'] %}
      - sls: {{ slsfile }}
{%- endfor %}
{%- endif %}
{%- endfor %}
  

{# install plugins #}
{% for p in settings.plugins %}
vagrant_plugin_{{ p }}:
  cmd.run:
    - name: vagrant plugin install {{ p }}
    - runas: {{ user }}
    - unless: vagrant plugin list | grep -q {{ p }}
    - require:
      - pkg: vagrant_plugin_deps
{% endfor %}


{# after plugin install, create base boxes #}
{% for p in settings.plugins %}
{% if p == "vagrant-lxd" %}
create-lxd-ubuntu-box:
  cmd.run:
    - name: /usr/local/bin/vagrant-box-add-lxd-ubuntu.sh xenial
    - unless: /usr/local/bin/vagrant-box-add-lxd-ubuntu.sh --check xenial
    - require:
      - cmd: vagrant_plugin_{{ p }}

{% elif p == "vagrant-libvirt" %}
create-libvirt-ubuntu-box:
  cmd.run:
    - name: /usr/local/bin/vagrant-box-add-libvirt-ubuntu.sh xenial
    - unless: /usr/local/bin/vagrant-box-add-libvirt-ubuntu.sh --check xenial
    - require:
      - cmd: vagrant_plugin_{{ p }}
{% endif %}
{% endfor %}
