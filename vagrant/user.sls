include:
  - vagrant

{% from "vagrant/defaults.jinja" import settings with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

vagrant_plugin_deps:
  pkg.installed:
    - pkgs:
      - ruby-dev
{%- for p in settings.plugins %}
{%- if p.dependencies is defined %}
{%- for d in p.dependencies %}
      - {{ d }}
{%- endfor %}
{%- endif %}
{%- endfor %}


{% for p in settings.plugins %}
vagrant_plugin_{{ p.name }}:
  cmd.run:
    - name: vagrant plugin install {{ p.name }}
    - runas: {{ user }}
    - unless: vagrant plugin list | grep -q {{ p.name }}
    - require:
      - sls: vagrant
      - pkg: vagrant_plugin_deps

{% endfor %}

{% for p in settings.plugins %}
  {% if p.name = "vagrant-lxd" %}
create-lxd-ubuntu-box:
  cmd.run:
    - name: /usr/local/bin/vagrant-box-add-lxd-ubuntu.sh xenial
    - unless: /usr/local/bin/vagrant-box-add-lxd-ubuntu.sh --check xenial
    - require:
      - cmd: vagrant_plugin_{{ p.name }}

  {% elif p.name = "vagrant-libvirt" %}
create-libvirt-ubuntu-box:
  cmd.run:
    - name: /usr/local/bin/vagrant-box-add-libvirt-ubuntu.sh xenial
    - unless: /usr/local/bin/vagrant-box-add-libvirt-ubuntu.sh --check xenial
    - require:
      - cmd: vagrant_plugin_{{ p.name }}
  {% endif %}
{% endfor %}
