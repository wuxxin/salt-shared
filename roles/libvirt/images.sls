
volumes.images:
  cmd.run:
    - name: lvcreate -L {{ pillar.libvirt.volumes.images.size }} -n images {{ pillar.libvirt.volumes.images.vg }} && mkfs.{{ pillar.libvirt.volumes.images.fstype }} /dev/{{ pillar.libvirt.volumes.images.vg }}/images
    - unless: lvs {{ pillar.libvirt.volumes.images.vg }}/images
  mount.mounted:
    - name: {{ pillar.libvirt.volumes.images.mount }}
    - device: /dev/{{ pillar.libvirt.volumes.images.vg }}/images
    - fstype: {{ pillar.libvirt.volumes.images.fstype }}
    - mkmnt: True
    - persist: True
    - require:
      - cmd: volumes.images

/etc/libvirt/storage/autostart:
  file.directory:
    - makedirs: True

{%for n in ("default", "templates", "iso", "tmp") %}
{{ pillar.libvirt.volumes.images.mount }}/{{ n }}:
  file.directory:
    - makedirs: True
    - group: libvirtd
    - user: libvirt-qemu
    - dir_mode: 775
    - file_mode: 664
    - recurse:
        - user
        - group
        - mode
    - require:
      - group: libvirtd
      - mount: volumes.images

/etc/libvirt/storage/{{ n }}.xml:
  file.managed:
    - source: salt://roles/libvirt/imgtemplate.xml
    - template: jinja
    - context:
        pool: {{ n }}
        path: {{ pillar.libvirt.volumes.images.mount }}/{{ n }}
    - require:
      - file: {{ pillar.libvirt.volumes.images.mount }}/{{ n }}
    - prereq_in:
      - service: stopped_libvirt_bin

/etc/libvirt/storage/autostart/{{ n }}.xml:
  file.symlink:
    - target: /etc/libvirt/storage/{{ n }}.xml
    - require:
      - file: /etc/libvirt/storage/{{ n }}.xml
      - file: /etc/libvirt/storage/autostart
{% endfor %}

/etc/libvirt/storage:
  file.recurse:
    - source: {{ pillar.libvirt.storage if pillar['libvirt']['storage'] else 'salt://roles/libvirt/storage/' }}
    - prereq_in:
      - service: stopped_libvirt_bin

#{% for n in salt['file.find']('/etc/libvirt/storage',name='*', types='f') %}
#/etc/libvirt/storage/autostart/{{ n }}:
#  file.symlink:
#    - target: /etc/libvirt/storage/{{ n }}
#    - require:
#      - file: /etc/libvirt/storage/
#{% endfor %}


default_images:
  cmd.run:
    - onlyif: test -d {{ pillar.libvirt.volumes.images.mount }}/default
    - name: x=/var/lib/libvirt/images; if test -d $x; then cp -r $x/* {{ pillar.libvirt.volumes.images.mount }}/default; rm -r $x; fi
    - unless: test -h /var/lib/libvirt/images
    - require:
      - mount: volumes.images
      - file: {{ pillar.libvirt.volumes.images.mount }}/default
    - prereq_in:
      - service: stopped_libvirt_bin

/var/lib/libvirt/images:
  file.symlink:
    - target: /var/lib/libvirt/nonexisting
    - require: 
      - cmd: default_images

