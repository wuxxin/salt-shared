{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
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
  cmd.run:
    - name: true
    - require:
      - pkgrepo: salt_ppa

{% endif %}

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("salt_ppa", "saltstack/salt") }}

{% endif %}
