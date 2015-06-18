{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

whatsapp_ppa:
  pkgrepo.managed:
    - ppa: whatsapp-purple/ppa

pidgin_gnome_keyring_ppa:
  pkgrepo.managed:
    - ppa: pidgin-gnome-keyring/ppa
{% endif %} 
