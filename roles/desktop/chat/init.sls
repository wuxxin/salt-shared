include:
  - .ppa

chat:
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
      - pkgrepo: whatsapp_ppa
      - pkgrepo: pidgin_gnome_keyring_ppa
