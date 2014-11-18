
{% macro deploy_vagrant_vm(settings) %}

{{ vagrant_up(settings) }}
{{ saltify_vm(settings) }}
{{ network_cleanup(settings) }}
{{ vagrant_halt(settings) }}

{{ detach_vm(settings) }}
{{ macro vm-move-network(name) }}
{{ macro vm-copy-resize(name) }}
{{ macro spicify(name) }}
{{ macro set_autostart(settings, autostart='on') }}

{{ vm_start(settings) }}

{% endmacro %}


{% macro vagrant_up(settings) %}
{{ settings.hostname }}-vm-up:
  cmd.run:
    - cwd: {{ settings.target }}
    - user: {{ settings.user }}
    - name: vagrant up
{% endmacro %}

{% macro vagrant_halt(settings) %}
{{ settings.hostname }}-vm-halt:
  cmd.run:
    - cwd: {{ settings.target }}
    - user: {{ settings.user }}
    - name: vagrant halt
{% endmacro %}


{% macro saltify_vm(settings) %}
template_dir:
  file.directory:
    - name: {{ settings.target }}/salt/key
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - makedirs: true

generate_and_accept_minion_key:
  cmd.run:
    - cwd:  {{ settings.target }}/salt/key
    - name: "salt-key -y --gen-keys={{ hostname }} && cp {{ hostname }}.pub /etc/salt/pki/master/minions/{{ hostname }}"
    - unless: test -f /etc/salt/pki/master/minions/{{ hostname }}
    - require:
      - file: template_dir
    - require_in:
      - cmd: generate_vm

modify_vagrant_file:
  cmd.run:
    - cwd: {{ settings.target }}
    - user: {{ settings.user }}
    - name: 
  config.vm.provision :salt do |salt|
    salt.minion_key = "salt/key/{{ settings.hostname }}.pem"
    salt.minion_pub = "salt/key/{{ settings.hostname }}.pub"
  end

vagrant_provision:
  cmd.run:
    - cwd: {{ settings.target }}
    - user: {{ settings.user }}
    - name: vagrant provision
{% endmacro %}
  

{% macro network_cleanup(settings) %}
copy
salt://roles/imgbuilder/vagrant/files/network-cleanup.sh
to target /tmp
and execute
vagrant shell --command "/bin/bash" -c "
{% endmacro %}


{% macro vm_detach(name) %}
{{ name }}-vm-detach:
  file.absent:
    - name: /mnt/images/templates/imgbuilder/{{ name }}-vm/.vagrant
    - require:
      - cmd: {{ name }}-vm-halt
  cmd.run:
    - name: virsh dumpxml $vmname --inactive > /mnt/images/templates/imgbuilder/{{ name }}-vm/libvirt.xml
    - creates: /mnt/images/templates/imgbuilder/{{ name }}-vm/libvirt.xml
    - require:
      - file: {{ name }}-vm-detach
{% endmacro %}


{% macro vm-memsize-cpus(name,memsize,cpus) %}
{{ name }}-vm-memsize-cpus:
  cmd.run:
    - name: /mnt/images/templates/imgbuilder/scripts/memsize-cpus {{ name }} 768 2
    - require:
      - cmd: {{ name }}-vm-detach
{% endmacro %}

{% macro vm-move-network(name) %}
{{ name }}-vm-move-network:
  cmd.run:
msub "<interface type=.+<mac address=.([0-9a-f:]+).+</interface>" "<interface type=\"bridge\"><mac address=\"\\1\"/><source bridge=\"$bridge\"/></interface>" > ${vmname}.xml    - name: /mnt/images/templates/imgbuilder/scripts/def2bridge {{ name }} br1
    - require:
      - cmd: {{ name }}-vm-memsize-cpus
{% endmacro %}

{% macro spicify(name) %}
{% for i, ms,me,co in [
(0, "<video>", "</video>", "<video><model type=\"qxl\"/></video>"),
(1, "<channel type=.spicevmc", "</channel>", ""),
(2, "<graphics type", "</channel>", "<graphics type=\"spice\" autoport=\"yes\" /><channel type=\"spicevmc\"><target type=\"virtio\" name=\"com.redhat.spice.0\"/></channel>"),
] %}

{{ name }}-spicify-{{ i }}
  file.blockreplace:
    - name: /mnt/images/templates/imgbuilder/{{ name }}-vm/libvirt.xml
    - marker_start: ms
    - marker_end: me
    - content: co
    - require: 
      - cmd: {{ name }}-vm-move-network
{% endfor %}

{% endmacro %}

{% macro vm-copy-resize(name) %}
{{ name }}-vm-copy-resize:
  cmd.run:
    - name: /mnt/images/templates/imgbuilder/scripts/copy_resize {{ name }} vg0 15G
virt-resize $sourcefile /dev/mapper/$volumegroup-$volumename $expand_pt $expand_lv

    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: {{ name }}-spicify
{% endmacro %}


{% macro set_autostart(settings, autostart='on') %}
set_autostart_vm:
  module.run:
    - name: virt.set_autostart
    - vm: {{ settings.hostname }}
    - state: {{ autostart }}
{% endmacro %}
