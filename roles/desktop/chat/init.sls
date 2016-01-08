include:
  - .ppa

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
    - require:
      - cmd: whatsapp_ppa
      - cmd: pidgin_gnome_keyring_ppa

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
    - require:
      - pkgrepo: gajim_ppa
