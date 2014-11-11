{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}

# if grains['os'] == '(RedHat|CentOS)'

{% if grains['os'] == 'Debian' %}
salt_ppa:
  pkgrepo.managed:
    - name: deb http://debian.saltstack.com/debian {{ grains['lsb_distrib_codename'] }}-saltstack main
    - humanname: "Debian salt Repository"
    - file: /etc/apt/sources.list.d/salt_ppa.list
    - key_url: http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
salt_ppa:
  pkgrepo.managed:
    - ppa: saltstack/salt
{#
    - name: deb http://ppa.launchpad.net/saltstack/salt/ubuntu {{ grains['lsb_distrib_codename'] }} main
    - humanname: "Ubuntu salt Repository"
    - file: /etc/apt/sources.list.d/salt_ppa.list
    - keyid: 7a82b743b9b8e46f12c733fa4759fa960e27c0a6
    - keyserver: keyserver.ubuntu.com
#}
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
