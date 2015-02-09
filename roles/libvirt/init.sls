#!jinja|yaml

include:
  - remotefs
  - .kernel
  - .grub
  - .storage
  - .network
  - .salt_master

default_libvirt_settings:
  file.managed:
    - name: /etc/default/libvirt-bin
    - contents: |
        # Defaults for libvirt-bin initscript (/etc/init.d/libvirt-bin)
        # This is a POSIX shell fragment
        # Start libvirtd to handle qemu/kvm:
        start_libvirtd="yes"
        # options passed to libvirtd, add "-l" to listen on tcp
        libvirtd_opts="-d -l"
        # pass in location of kerberos keytab
        #export KRB5_KTNAME=/etc/libvirt/libvirt.keytab
    - require:
      - pkg: libvirt
    - watch_in:
      - service: libvirt

default_libvirt_keys:
  libvirt:
    - keys
    - require:
      - pkg: libvirt

{#for a in ['vnc_tls', 'vnc_tls_x509_verify', 'spice_tls',] %}
disabled for now

qemu_conf_{{ a }}:
  file.replace:
    - name: /etc/libvirt/qemu.conf
    - pattern: '.*{{ a }}.*=.*'
    - repl: "{{ a }} = 1"
    - require: 
      - pkg: libvirt
    - watch_in:
      - service: libvirt
{% endfor %}

{% for a in ['/etc/pki/libvirt-vnc', '/etc/pki/libvirt-spice'] %}
disabled for now
symlinks_{{ a }}:
  file.symlink:
    - name: {{ a }}
    - source: /etc/pki/libvirt
    - require: 
      - libvirt: default_libvirt_keys
    - watch_in:
      - service: libvirt
{% endfor #}

libvirt:
  pkg.installed:
    - pkgs:
      - libvirt-bin
      - libguestfs-tools
      - ubuntu-virt-server
      - qemu-kvm
      - python-openssl {# is needed for states.libvirt.keys #}
      - gnutls-bin {# is needed for states.libvirt.keys #}
      - virt-viewer
      - virt-manager
      - virtinst
      - virt-top
      - python-libvirt
      - python-spice-client-gtk
      - python-guestfs
      - libguestfs-tools
      - nbdkit
      - lvm2
      - cgroup-bin {# library and kernel support is needed, bin package catches requisites #}
      - multipath-tools
      - bridge-utils
      - vlan
  service:
    - running
    - name: libvirt-bin
    - enable: True
    - require:
      - pkg: libvirt
      - libvirt: default_libvirt_keys
      - sls: roles.libvirt.storage
      - sls: roles.libvirt.network
      - sls: roles.libvirt.kernel
      - sls: roles.libvirt.grub

