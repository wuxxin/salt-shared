{% if grains.salt_master|d(False) == True %}
include:
  - roles.salt.master

/etc/salt/master.d/libvirt.conf:
  file.managed:
    - contents: |
        virt:
          tunnel: true
    - watch_in:
      - service: salt-master

{% endif %}
