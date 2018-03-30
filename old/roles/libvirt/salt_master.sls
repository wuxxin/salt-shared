{% if grains.salt_master|d(False) == True %}
{# todo: make this also work if saltmaster is on a different host than libvirt role #}
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
