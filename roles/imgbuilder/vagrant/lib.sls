
{% macro deploy_vagrant_vm(vagrantdir, fqdn, saltify=False, spicify=False, disksize=None, memsize=None, cpus=None, user=None) %}

{% from roles.imgbuilder.defaults.jinja import settings as s %}
{% if user == None %}{% set user= s.user %}{% endif %}
{% set libvirt_file= vagrantdir+ "/libvirt.xml" %}
{% set id_file= vagrantdir+ "/id" %}

{{ vagrant_up(vagrantdir, user) }}
{% if saltify == True %}
  {{ vagrant_saltify_running(vagrantdir, user, fqdn) }}
{% endif %}
{{ vagrant_network_cleanup(vagrantdir, user) }}
{{ vagrant_halt(vagrantdir, user) }}
{{ vagrant_detach(vagrantdir, user, id_file) }}

{{ vm_memsize_cpus(id_file, memsize, cpus) }}

{{ vm_dump_xml(vagrantdir, user, id_file, libvirt_file) }}
{% if spicify == True %}{{ vm_spicify(libvirt_file) }}{% endif %}
{{ vm_rename(libvirt_file, fqdn) }}
{{ vm_move_network(libvirt_file, s.libvirt.final_deploy_bridge) }}
{{ vm_update(libvirt_file, user) }}

{{ vm_disk_transfer(id_file, s.libvirt.final_deploy_lvm, disksize) }}
{{ vm_start(id_file, autostart=true) }}

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


{% macro vagrant_saltify_running(target, user, fqdn) %}
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
    - name: 'vagrant rsync && vagrant ssh -c "/bin/bash" -- -c "cd /vagrant/salt && sudo ./bootstrap-salt.sh -X"'
    - require:
      - file: download_bootstrap_salt_{{ fqdn }}
{% endmacro %}
  

{% macro vagrant_network_cleanup(target, user) %}
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


{% macro vagrant_detach(target, user, id_file) %}
{{ vagrant_halt(target, user) }}

{{ target }}-save-current-id:
  cmd.run:
    - name: cp {{ target }}.vagrant/machines/default/libvirt/id {{ id_file }}

{{ target }}-vm-detach:
  file.absent:
    - name: {{ target }}/.vagrant
    - require:
      - cmd: {{ target }}-save-current-id
{% endmacro %}


{% macro vm_memsize_cpus(idfile, memsize, cpus) %}

{% if memsize is not None %}
change_memsize_{{ idfile }}:
  module.run:
    - name: virt.setmem
    - vm_: {{ salt['cmd.run_stdout']('cat '+ idfile) }}
    - memory: {{ memsize }}
    - config: True
{% endif %}

{% if cpus is not None %}
change_cpus_{{ idfile }}:
  module.run:
    - name: virt.setvcpus
    - vm_: {{ salt['cmd.run_stdout']('cat '+ idfile) }}
    - vcpus: {{ cpus }}
    - config: True
{% endif %}

{% endmacro %}


{% macro vm_dump_xml(target, user, id_file, xml_file) %}

{{ target }}-dump_xml:
  cmd.run:
    - name: virsh dumpxml `cat {{ id_file }}` --migratable > {{ xml_file }}
    - creates: {{ xml_file }}
  file.managed:
    - name: {{ xml_file }}
    - file_mode: 0660
    - user: {{ user }}
    - require:
      - cmd: {{ target }}-dump_xml

{% endmacro %}


{% macro vm_update(xml_file)

{{ xml_file }}-vm-update:
  cmd.run:
    - name: virsh define {{ xml_file }}

{% endmacro %}


{% macro vm_spicify(xml_file) %}
{% for i, ms,me,co in [
(0, "<video>", "</video>", "<video><model type=\"qxl\"/></video>"),
(1, "<channel type=.spicevmc", "</channel>", ""),
(2, "<graphics type", "</channel>", "<graphics type=\"spice\" autoport=\"yes\" /><channel type=\"spicevmc\"><target type=\"virtio\" name=\"com.redhat.spice.0\"/></channel>"),
] %}

{{ xml_file }}-spicify-{{ i }}:
  file.blockreplace:
    - name: {{ xml_file }}
    - marker_start: {{ ms }}
    - marker_end: {{ me }}
    - content: {{ co }}
{% endfor %}

{% endmacro %}


{% macro vm_move_network(xml_file, target_network) %}

{% if target_network != 'default' %}
{{ xml_file }}-vm_move_network:
  file.replace:
    - name: {{ xml_file }}
    - pattern: |
        <interface type=.+<mac address=.([0-9a-f:]+).+</interface>
    - repl: |
        <interface type="bridge"><mac address="\1"><source bridge="{{ target_network }}"/></interface>
    - flags: ['MULTILINE']
    - bufsize: 'file'
    - user: {{ user }}
{% endif %}

{% endmacro %}


{% macro vm_update(xml_file)

{{ xml_file }}-vm-update:
  cmd.run:
    - name: virsh define {{ xml_file }}

{% endmacro %}


{% macro vm_disk_transfer(id_file, lvm_group, disksize) %}

"{{ target }}/image-file-to-lvm.sh":
  file.managed:
    - user: {{ user }}
    - source:  salt://roles/imgbuilder/vagrant/files/image-file-to-lvm.sh
    - mode: 755
  cmd.run:
    - name: '{{ target }}/image-file-to-lvm.sh $(cat {{ id_file }}) {{ lvm_group }} {{ disksize }}'

{% endmacro %}


{% macro vm_start(id_file, autostart=true) %}

{% set auto_state='on' if autostart else 'off' %}
change_autostart_{{ id_file }}:
  module.run:
    - name: virt.set_autostart
    - vm_: {{ salt['cmd.run_stdout']('cat '+ id_file) }}
    - state: {{ auto_state }}

start_{{ id_file }}:
  module.run:
    - name: virt.start
    - vm_: {{ salt['cmd.run_stdout']('cat '+ id_file) }}
    - require:
      - module: change_autostart_{{ id_file }}

{% endmacro %}
