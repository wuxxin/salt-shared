imgbuilder:
  pkg:
    - installed
    - pkgs:
      - qemu-kvm
      - qemu-utils
      - libguestfs-tools
  group:
    - present
  user:
    - present
    - gid: imgbuilder
    - home: /home/imgbuilder
    - shell: /bin/bash
    - groups:
      - kvm
      - libvirtd
    - require:
      - group: imgbuilder
      - pkg: imgbuilder
  file.directory:
    - name: /home/imgbuilder/.ssh
    - user: imgbuilder
    - group: imgbuilder
    - mode: 700
    - require:
      - user: imgbuilder

