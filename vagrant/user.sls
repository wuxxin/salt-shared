{% from "vagrant/defaults.jinja" import settings, dependencies with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{# include requisite states needed for plugins #}
include:
  - vagrant
{%- for plugin in settings.plugins %}
  {%- if plugin in dependencies and dependencies[plugin]['sls'] is defined %}
    {%- for slsfile in dependencies[plugin]['sls'] %}
  - {{ slsfile }}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
{%- if settings.virtualbox|d(false) %}
  - desktop.emulation.virtualbox
{%- endif %}


vagrant_plugin_deps:
  pkg.installed:
    - pkgs:
      - ruby-dev
{# install additional build dependencies for plugins
  if origin=upstream or plugin not available as distro package #}
{%- for plugin in settings.plugins %}
  {%- if settings.origin == 'upstream' or
    salt['cmd.retcode']('apt-cache show '+ plugin) != 0 %}
    {%- if plugin in dependencies and dependencies[plugin]['build'] is defined %}
      {%- for pkg in dependencies[plugin]['build'] %}
      - {{ pkg }}
      {%- endfor %}
    {%- endif %}
  {%- endif %}
{%- endfor %}
    - require:
      - sls: vagrant
{%- for plugin in settings.plugins %}
  {# require sls files needed for plugins #}
  {%- if plugin in dependencies and dependencies[plugin]['sls'] is defined %}
    {%- for slsfile in dependencies[plugin]['sls'] %}
      - sls: {{ slsfile }}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
  

{% for plugin in settings.plugins %}
vagrant_plugin_{{ plugin }}:
  {%- if settings.origin != 'upstream' and 
    salt['cmd.retcode']('apt-cache show '+ plugin) == 0 %}
    {# install plugins as distro package if available and origin != upstream #}
  pkg.installed:
    - name: {{ plugin }}
    - require:
      - pkg: vagrant_plugin_deps
  cmd.run:
    - name: true
    - require:
      - pkg: vagrant_plugin_{{ plugin }}
  {%- else %}
  cmd.run:
    - name: vagrant plugin install {{ plugin }}
    {%- if plugin == 'vagrant-libvirt' %}
    {# XXX workaround for vagrant-libvirt not compiling on bionic and newer #}
    - env:
      - CONFIGURE_ARGS: "with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib64"
    {%- endif %}
    - runas: {{ user }}
    - unless: vagrant plugin list | grep -q {{ plugin }}
    - require:
      - pkg: vagrant_plugin_deps
  {%- endif %}
{% endfor %}


{# after plugin install, create base boxes #}
{% for plugin in settings.plugins %}
{% if plugin == "vagrant-lxd" %}
create-lxd-ubuntu-box:
  cmd.run:
    - name: /usr/local/bin/vagrant-box-add-ubuntu.sh --only-lxd --yes
    - unless: /usr/local/bin/vagrant-box-add-ubuntu.sh --only-lxd --check
    - runas: {{ user }}
    - require:
      - cmd: vagrant_plugin_{{ plugin }}
{% elif plugin == "vagrant-libvirt" %}
create-libvirt-ubuntu-box:
  cmd.run:
    - name: /usr/local/bin/vagrant-box-add-ubuntu.sh --only-libvirt --yes
    - unless: /usr/local/bin/vagrant-box-add-ubuntu.sh --only-libvirt --check
    - runas: {{ user }}
    - require:
      - cmd: vagrant_plugin_{{ plugin }}
{% endif %}
{% endfor %}
