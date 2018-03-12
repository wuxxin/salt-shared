{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("whatsapp_ppa", 
  "whatsapp-purple/ppa", require_in= "pkg: pidgin") }}
{{ apt_add_repository("pidgin_gnome_keyring_ppa", 
  "pidgin-gnome-keyring/ppa", require_in= "pkg: pidgin") }}
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

