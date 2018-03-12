
{% if grains['os_family'] == 'Debian' %}
gajim_ppa:
  pkgrepo.managed:
    - repo: 'deb ftp://ftp.gajim.org/debian unstable main'
    - file: /etc/apt/sources.list.d/gajim.list
    - key_url: salt://desktop/chat/gajim_key.asc
    - require_in:
      - pkg: gajim

{% endif %}

gajim:
  pkg.installed:
    - pkgs:
      - gajim
      - python-osmgpsmap
      - python-pygoocanvas
      - python-avahi
      - python-farstream
      - python-gnomekeyring
      - python-gupnp-igd
      - python-kerberos
      - python-pycurl
      - python-pyasn1
      - python-dbus
      - python-crypto
      - notification-daemon
