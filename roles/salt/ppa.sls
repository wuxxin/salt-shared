{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}


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
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
