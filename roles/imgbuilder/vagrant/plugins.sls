include:
  - .local-ruby
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

{% set gem_plugins = ["sahara", "vagrant-cachier", "vagrant-omnibus", "vagrant-mutate", "vagrant-triggers", "vagrant-libvirt", "vagrant-reload"] %}
{# ,"gusteau", "vagrant-bindfs", #}

{% set git_plugins = [] %}
{# set git_plugins = [("vagrant-libvirt", "https://github.com/pradels/vagrant-libvirt.git"),] #}

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
