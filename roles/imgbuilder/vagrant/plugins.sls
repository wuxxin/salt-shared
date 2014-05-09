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


{% gem-plugins = ["sahara", "vagrant-cachier", "vagrant-omnibus", "vagrant-mutate", 
    "vagrant-bindfs", "vagrant-windows", "docker-provider", "gusteau"] %}
{% git-plugins = [("vagrant-libvirt", "https://github.com/pradels/vagrant-libvirt.git"),] %}


{% for t,s in git-plugins %}

{% build_dir=/home/imgbuilder/.build/{{ t }} %}

vagrant_compile_plugin_{{ t }}:
  git.installed:
    - name: {{ s }}
    - target: {{ build_dir }}
    - unless: vagrant plugin list | grep -q {{ t }}
    - user: imgbuilder
    - require:
      - pkg: vagrant
      - pkg: vagrant_plugin_deps
      - cmd: default-local-ruby-imgbuilder
  cmd.run:
    - name: cd {{ build_dir }}; bundle install; touch {{ build_dir }}/cmd.run.vagrant_compile_plugin_{{ t }}
    - unless: test -f {{ build_dir }}/cmd.run.vagrant_compile_plugin_{{ t }}
    - require:
      - git: vagrant_compile_plugin_{{ t }}

vagrant_plugin_{{ t }}:
  cmd.run:
    - name: vagrant plugin install  
    - unless: vagrant plugin list | grep -q {{ t }}
    - user: imgbuilder
    - require:
      - cmd: vagrant_compile_plugin_{{ t }}

{% endfor %}

{% for t in gem-plugins %}

vagrant_plugin_{{ t }}:
  cmd.run:
    - name: vagrant plugin install {{ t }} 
    - unless: vagrant plugin list | grep -q {{ t }}
    - user: imgbuilder
    - require:
      - pkg: vagrant
      - pkg: vagrant_plugin_deps

{% endfor %}

