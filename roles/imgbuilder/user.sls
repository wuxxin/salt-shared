
{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

imgbuilder:
  pkg:
    - installed
    - pkgs:
      - qemu-kvm
      - qemu-utils
      - libguestfs-tools
  group:
    - present
    - name: {{ s.user }}
  user:
    - present
    - name: {{ s.user }}
    - gid: {{ s.user }}
    - home: /home/{{ s.user }}
    - shell: /bin/bash
    - remove_groups: False
    - groups:
      - kvm
      - libvirtd
    - require:
      - group: imgbuilder
      - pkg: imgbuilder
  file.directory:
    - name: /home/{{ s.user }}/.ssh
    - user: {{ s.user }}
    - group: {{ s.user }}
    - mode: 700
    - require:
      - user: imgbuilder

{% from "ssh/lib.sls" import ssh_keys_update %}
{{ ssh_keys_update(s.user, salt['pillar.get'](adminkeys_present, False), salt['pillar.get'](adminkeys_absent, False)) }}
