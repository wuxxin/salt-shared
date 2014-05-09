include:
  - roles.imgbuilder.local-ruby

vagrant_plugin_deps:
  pkg.installed:
    - pkgs:
      - libxslt1-dev
      - libxml2-dev
      - zlib1g-dev
      - libvirt-dev
      - qemu-utils
    - require:
      - pkg: vagrant

{% set gem_plugins = ["sahara", "vagrant-cachier", "vagrant-omnibus", "vagrant-mutate", 
    "vagrant-bindfs",  "gusteau"] %} # "vagrant-windows", "docker-provider",
{% set git_plugins = [("vagrant-libvirt", "https://github.com/pradels/vagrant-libvirt.git"),] %}

{% for t,s in git_plugins %}

{% set build_dir="/home/imgbuilder/.build/"+ t %}

vagrant_compile_plugin_{{ t }}:
  git.latest:
    - name: {{ s }}
    - target: {{ build_dir }}
    - user: imgbuilder
    - submodules: True
    - unless: vagrant plugin list | grep -q {{ t }}
    - require:
      - pkg: vagrant
      - pkg: vagrant_plugin_deps
      - cmd: default-local-ruby-imgbuilder
  cmd.run:
    - name: cd {{ build_dir }}; bundle install; rake build; touch {{ build_dir }}/cmd.run.vagrant_compile_plugin_{{ t }}
    - unless: test -f {{ build_dir }}/cmd.run.vagrant_compile_plugin_{{ t }}
    - require:
      - git: vagrant_compile_plugin_{{ t }}

vagrant_plugin_{{ t }}:
  cmd.run:
    - name: vagrant plugin install {{ build_dir }}/pkg/{{ t }}*.gem
    - unless: vagrant plugin list | grep -q {{ t }}
    - user: imgbuilder
    - require:
      - cmd: vagrant_compile_plugin_{{ t }}

{% endfor %}

{% for t in gem_plugins %}

vagrant_plugin_{{ t }}:
  cmd.run:
    - name: vagrant plugin install {{ t }} 
    - unless: vagrant plugin list | grep -q {{ t }}
    - user: imgbuilder
    - require:
      - pkg: vagrant
      - pkg: vagrant_plugin_deps

{% endfor %}

