
# vagrant-libvirt-hypervisor (kvm/xen) salt-cloud provider

#state.sls roles.imgbuilder.tools.list_all

{% macro vm-salt-preseed(minion_id_aka_hostname%}
# salt-key --gen-keys=[minion_id]
# cp [minion_id].pub /etc/salt/pki/master/minions/[minion_id]
{% endmacro %}

{% macro vm-Vagrantfile(name, hostname, options) %}
# render target vagrantfile with replaced provisioner and replaced minion_keys and custom pillar overwriting memsize and cpus
{% endmacro %}

modify Vagrantfile to exclude old provision, and include new provision

up if not running

shell provision:
  clean host file from salt hostname
  change hostname
  disable vagrant user, remove vagrant sudo, remove vagrant authorized_keys
  re/provision with salt-client, new client keys, minion-id, and master key


{% macro vm-halt(name) %}
{{ name }}-vm-halt:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/{{ name }}-vm; vagrant halt
    - user: imgbuilder
    - group: imgbuilder
#    - require:
#      - cmd: {{ name }}-vm-provision
{% endmacro %}

{% macro vm-detach(name) %}
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

{% macro vm-memsize-cpus(name,memsíze,cpus) %}
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

{% macro present-autostart(name) %}
{{ name }}-present-autostart:
  cmd.run:
    - name: /mnt/images/templates/imgbuilder/scripts/start_and_autostart {{ name }}
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: {{ name }}-vm-copy-resize
{% endmacro %}

