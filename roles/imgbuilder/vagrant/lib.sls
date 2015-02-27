{% macro deploy_vagrant_vm(vagrantdir, fqdn, saltify=False, spicify=False, disksize=None, memsize=None, cpus=None, user=None) %}

{% from roles.imgbuilder.defaults.jinja import settings as s %}
{% if user == None %}{% set user= s.user %}{% endif %}
{% set libvirt_xml_file= vagrantdir+ "/libvirt.xml" %}

{{ vagrant_up(vagrantdir, user) }}
{% if saltify == True %}{{ saltify_running(vagrantdir, user, fqdn) }}{% endif %}
{{ network_cleanup(vagrantdir, user) }}
{{ vagrant_halt(vagrantdir, user) }}

{{ vagrant_detach(vagrantdir, user, libvirt_xml_file) }}

{{ vm_move_network(libvirt_xml_file, s.libvirt.final_deploy_bridge) }}
{{ vm_memsize_cpus(libvirt_xml_file, memsize, cpus) }}
{% if spicify == True %}{{ vm_spicify(libvirt_xml_file) }}{% endif %}
{{ vm_copy_resize(libvirt_xml_file, fqdn, s.libvirt.final_deploy_lvm, disksize) }}

{{ vm_update(libvirt_xml_file, user, start=true, autostart=true) }}

{% endmacro %}


{% macro vagrant_up(target, user) %}
{{ target }}-vm-up:
  cmd.run:
    - cwd: {{ target }}
    - user: {{ user }}
    - name: vagrant up
{% endmacro %}


{% macro vagrant_halt(target, user) %}
{{ target }}-vm-halt:
  cmd.run:
    - cwd: {{ target }}
    - user: {{ user }}
    - name: vagrant halt
{% endmacro %}


{% macro saltify_running(target, user, fqdn) %}
{% from "roles/salt/defaults.jinja" import settings as salt_settings with context %}

template_dir_salt_key_{{ fqdn }}:
  file.directory:
    - name: {{ target }}/salt/key
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true

generate_and_accept_minion_key_{{ fqdn }}:
  cmd.run:
    - cwd:  {{ target }}/salt/key
    - name: "salt-key -y --gen-keys={{ fqdn }} && cp {{ fqdn }}.pub /etc/salt/pki/master/minions/{{ fqdn }} && chown {{ user }} {{ fqdn }}.*"
    - unless: test -f {{ target }}/salt/key/{{ fqdn }}.pem
    - require:
      - file: template_dir_salt_key_{{ fqdn }}

download_bootstrap_salt_{{ fqdn }}:
  file.managed:
    - name: {{ target }}/salt/bootstrap-salt.sh
    - user: {{ user }}
    - source: {{ salt_settings.install.bootstrap }}
    - source_hash: {{ salt_settings.install.bootstrap_hash }}
    - mode: 755
    - require:
      - cmd: generate_and_accept_minion_key_{{ fqdn }}

transfer_and_bootstrap_{{ fqdn }}:
  cmd.run:
    - cwd: {{ target }}
    - user: {{ user }}
    - name: 'vagrant rsync && vagrant ssh -c "/bin/bash" -- -c "cd /vagrant/salt && sudo ./bootstrap-salt.sh something"'
    - require:
      - file: download_bootstrap_salt_{{ fqdn }}

{% endmacro %}
  

{% macro network_cleanup(target, user) %}
"{{ target }}/network-cleanup.sh":
  file.managed:
    - user: {{ user }}
    - source:  salt://roles/imgbuilder/vagrant/files/network-cleanup.sh
    - mode: 755
  cmd.run:
    - cwd: {{ target }}
    - user: {{ user }}
    - name: 'vagrant rsync && vagrant ssh -c "/bin/bash" -- -c "cd /vagrant && sudo ./network-cleanup.sh"'
    - require:
      - file: "{{ target }}/network-cleanup.sh"

{% endmacro %}


{% macro vagrant_detach(target, user, libvirt_xml_file) %}
{{ vagrant_halt(target, user) }}

{{ target }}-vm-detach:
  cmd.run:
    - name: virsh dumpxml `cat {{ target }}.vagrant/machines/default/libvirt/id` --migratable > {{ libvirt_xml_file }}
    - creates: {{ libvirt_xml_file }}
    - require:
      - cmd: {{ target }}-vm-halt
  file.absent:
    - name: {{ target }}/.vagrant
    - require:
      - cmd: {{ target }}-vm-detach

{{ target }}-vm-xmlfile:
  file.managed:
    - name: {{ libvirt_xml_file }}
    - file_mode: 0660
    - user: {{ user }}
    - require: 
      - file: {{ target }}-vm-detach

{% endmacro %}


{% macro vm_move_network(xmlfile, target_network) %}

{% if target_network != 'default' %}
{{ xmlfile }}-vm_move_network:
  file.replace:
    - name: {{ xmlfile }}/libvirt.xml
    - pattern: |
        <interface type=.+<mac address=.([0-9a-f:]+).+</interface>
    - repl: |
        <interface type="bridge"><mac address="\1"><source bridge="{{ target_network }}"/></interface>
    - flags: ['MULTILINE']
    - bufsize: 'file'
    - user: {{ user }}
{% endif %}

{% endmacro %}


{% macro vm_memsize_cpus(xmlfile,memsize,cpus) %}

# noop currently

{% endmacro %}


{% macro vm_spicify(xmlfile) %}
{% for i, ms,me,co in [
(0, "<video>", "</video>", "<video><model type=\"qxl\"/></video>"),
(1, "<channel type=.spicevmc", "</channel>", ""),
(2, "<graphics type", "</channel>", "<graphics type=\"spice\" autoport=\"yes\" /><channel type=\"spicevmc\"><target type=\"virtio\" name=\"com.redhat.spice.0\"/></channel>"),
] %}

{{ xmlfile }}-spicify-{{ i }}:
  file.blockreplace:
    - name: {{ xmlfile }}
    - marker_start: {{ ms }}
    - marker_end: {{ me }}
    - content: {{ co }}
{% endfor %}

{% endmacro %}


{% macro vm_copy_resize(xmlfile, fqdn, s.libvirt.final_deploy_lvm, disksize) %}

"{{ target }}/image-file-to-lvm.sh":
  file.managed:
    - user: {{ user }}
    - source:  salt://roles/imgbuilder/vagrant/files/image-file-to-lvm.sh
    - mode: 755
  cmd.run:
    - name: '{{ target }}/image-file-to-lvm.sh {{ xmlfile }} {{ fqdn }} s.libvirt.final_deploy_lvm'

{% endmacro %}


{% macro vm_update(xmlfile, user, start=true, autostart=true) %}

{{ xmlfile }}-vm-update:
  cmd.run:
    - name: virsh define {{ xmlfile }}

{{ set_autostart(libvirt_xml_file, autostart='on') }}

{% endmacro %}
