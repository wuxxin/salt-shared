
{% macro deploy_vagrant_vm(vagrantdir, fqdn, disksize=None, memsize=None, cpus=None, user=None) %}

{% if user = None %}
{% from roles.imgbuilder.defaults.jinja import settings as s %}
{% set user= s.user %}
{% endif %}

{{ vagrant_up(vagrantdir, user) }}
{{ saltify_vm(vagrantdir, user, fqdn) }}
{{ network_cleanup(vagrantdir, user) }}
{{ vagrant_halt(vagrantdir, user) }}

{% set libvirt_id = detach_vm(vagrantdir, user) }}
{{ vm_move_network(libvirt_id) }}
{{ spicify(libvirt_id) }}
{{ vm_copy_resize(libvirt_id) }}

{{ set_autostart(libvirt_id, autostart='on') }}
{{ vm_start(libvirt_id) }}

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

{% macro saltify_vm(target, user, fqdn) %}
template_dir:
  file.directory:
    - name: {{ target }}/salt/key
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true

generate_and_accept_minion_key:
  cmd.run:
    - cwd:  {{ target }}/salt/key
    - name: "salt-key -y --gen-keys={{ fqdn }} && cp {{ fqdn }}.pub /etc/salt/pki/master/minions/{{ fqdn }}"
    - unless: test -f /etc/salt/pki/master/minions/{{ fqdn }}
    - require:
      - file: template_dir
    - require_in:
      - cmd: generate_vm

modify_vagrant_file:
  cmd.run:
    - cwd: {{ target }}
    - user: {{ user }}
    - name: 
  config.vm.provision :salt do |salt|
    salt.minion_key = "salt/key/{{ fqdn }}.pem"
    salt.minion_pub = "salt/key/{{ fqdn }}.pub"
  end

vagrant_provision:
  cmd.run:
    - cwd: {{ target }}
    - user: {{ user }}
    - name: vagrant provision
{% endmacro %}
  

{% macro network_cleanup(target, user) %}
copy
salt://roles/imgbuilder/vagrant/files/network-cleanup.sh
to target /tmp
and execute
vagrant shell --command "/bin/bash" -c "
{% endmacro %}


{% macro vm_detach(target, user, fqdn) %}
{{ vagrant_halt(target, user) }}

{{ target }}-vm-detach:
  file.absent:
    - name: {{ target }}/.vagrant
    - require:
      - cmd: {{ target }}-vm-halt
  cmd.run:
    - name: virsh dumpxml {{ fqdn }} --inactive > {{ target }}/libvirt.xml
    - creates: {{ target}}/libvirt.xml
    - require:
      - file: {{ target }}-vm-detach
  file.managed:
    - name: {{ target }}/libvirt.xml
    - file_mode: 0664
    - user: {{ user }}
    - require: 
      - cmd: {{ target }}-vm-detach

{% endmacro %}


{% macro vm_memsize_cpus(name,memsize,cpus) %}
{{ name }}-vm_memsize_cpus:
  cmd.run:
    - name: /mnt/images/templates/imgbuilder/scripts/memsize-cpus {{ name }} 768 2
    - require:
      - cmd: {{ name }}-vm-detach
{% endmacro %}

{% macro vm_move_network(target) %}
{{ target }}-vm_move_network:
  cmd.run:
msub "<interface type=.+<mac address=.([0-9a-f:]+).+</interface>" "<interface type=\"bridge\"><mac address=\"\\1\"/><source bridge=\"$bridge\"/></interface>" > ${vmname}.xml    - name: /mnt/images/templates/imgbuilder/scripts/def2bridge {{ name }} br1
    - require:
      - cmd: {{ name }}-vm_memsize-cpus
{% endmacro %}

{% macro spicify(target, fqdn) %}
{% for i, ms,me,co in [
(0, "<video>", "</video>", "<video><model type=\"qxl\"/></video>"),
(1, "<channel type=.spicevmc", "</channel>", ""),
(2, "<graphics type", "</channel>", "<graphics type=\"spice\" autoport=\"yes\" /><channel type=\"spicevmc\"><target type=\"virtio\" name=\"com.redhat.spice.0\"/></channel>"),
] %}

{{ target }}-spicify-{{ i }}
  file.blockreplace:
    - name: {{ target }}/libvirt.xml
    - marker_start: ms
    - marker_end: me
    - content: co
    - require: 
      - cmd: {{ target }}-vm_move_network
{% endfor %}

{% endmacro %}

{% macro vm_copy_resize(target, user, fqdn, size) %}
{{ name }}-vm_copy_resize:
  cmd.run:
    - name: /mnt/images/templates/imgbuilder/scripts/copy_resize {{ name }} vg0 15G
use cgroup 
for all interesting device nodes:
mkdir /sys/fs/cgroup/blkio/10mbwritepersecond
 echo "$devicenode  bytes_per_second" > /sys/fs/cgroup/blkio/10mbwritepersecond/blkio.throttle.write_bps_device"
create lvm that matches >= exact size of image
echo $! > /sys/fs/cgroup/blkio/10mbpersecond/tasks
cat /sys/fs/cgroup/blkio/10mbpersecond/tasks
qemu-img convert -O raw -S 1k empty-box-26g_vagrant_box_image.img /dev/vg0/test
virt-resize $sourcefile /dev/mapper/$volumegroup-$volumename $expand_pt $expand_lv &
remove from cgroups limit

    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: {{ name }}-spicify
{% endmacro %}

