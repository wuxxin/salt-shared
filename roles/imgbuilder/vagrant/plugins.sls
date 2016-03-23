{% set gem_plugins = ["vagrant-cachier", "vagrant-omnibus", "vagrant-mutate", "vagrant-triggers", "vagrant-libvirt", "vagrant-reload", "vagrant-proxyconf"] %}
{# FIXME: workaround for vagrant-libvirt at bottom of file #}

{% set git_plugins = [] %}
{# set git_plugins = [("vagrant-libvirt", "https://github.com/pradels/vagrant-libvirt.git"),] #}

include:
{%- if git_plugins %}
  - .local-ruby
{%- endif %}
  - .dirs

{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

vagrant_plugin_deps:
  pkg.installed:
    - pkgs:
      - libxslt1-dev
      - libxml2-dev
      - zlib1g-dev
      - libvirt-dev
      - qemu-utils
      - qemu-kvm
      - libguestfs-tools
    - require:
      - pkg: vagrant

{% for t,src in git_plugins %}

{% set build_dir="/home/"+ s.user+ "/.build/"+ t %}

vagrant_compile_plugin_{{ t }}:
  git.latest:
    - name: {{ src }}
    - target: {{ build_dir }}
    - user: {{ s.user }}
    - submodules: True
    - unless: vagrant plugin list | grep -q {{ t }}
    - require:
      - pkg: vagrant
      - pkg: vagrant_plugin_deps
      - cmd: default-local-ruby-imgbuilder
  cmd.run:
    - name: . .profile; cd {{ build_dir }}; bundle install; rake build; touch {{ build_dir }}/cmd.run.vagrant_compile_plugin_{{ t }}
    - user: {{ s.user }}
    - unless: test -f {{ build_dir }}/cmd.run.vagrant_compile_plugin_{{ t }}
    - require:
      - git: vagrant_compile_plugin_{{ t }}

vagrant_plugin_{{ t }}:
  cmd.run:
    - name: vagrant plugin install {{ build_dir }}/pkg/{{ t }}*.gem
    - user: {{ s.user }}
    - unless: vagrant plugin list | grep -q {{ t }}
    - require:
      - cmd: vagrant_compile_plugin_{{ t }}

{% endfor %}

{% for t in gem_plugins %}

vagrant_plugin_{{ t }}:
  cmd.run:
    - name: vagrant plugin install {{ t }}
    - user: {{ s.user }}
    - unless: vagrant plugin list | grep -q {{ t }}
    - require:
      - pkg: vagrant
      - pkg: vagrant_plugin_deps

{% endfor %}

vagrant_plugin_fog_libvirt:
  cmd.run:
    - name: vagrant plugin install --plugin-version 0.0.3 fog-libvirt
    - user: {{ s.user }}
    - unless: vagrant plugin list | grep -q fog-libvirt
    - require:
      - pkg: vagrant
      - pkg: vagrant_plugin_deps
