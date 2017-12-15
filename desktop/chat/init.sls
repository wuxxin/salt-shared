{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("whatsapp_ppa", 
  "whatsapp-purple/ppa", require_in= "pkg: pidgin") }}
{{ apt_add_repository("pidgin_gnome_keyring_ppa", 
  "pidgin-gnome-keyring/ppa", require_in= "pkg: pidgin") }}
{% endif %}

{% if grains['os_family'] == 'Debian' %}
gajim_ppa:
  pkgrepo.managed:
    - repo: 'deb ftp://ftp.gajim.org/debian unstable main'
    - file: /etc/apt/sources.list.d/gajim.list
    - key_url: salt://desktop/chat/gajim_key.asc
    - require_in:
      - pkg: gajim

{% endif %}

pidgin:
  pkg.installed:
    - pkgs:
      - pidgin
      - pidgin-blinklight
      - pidgin-awayonlock
      - pidgin-extprefs
      - pidgin-festival
      - pidgin-hotkeys
      - pidgin-themes
      - pidgin-skype
      - pidgin-otr
      - pidgin-gnome-keyring
      - pidgin-whatsapp
      - bitlbee

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
