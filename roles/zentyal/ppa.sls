{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

{% set zentyal_version = salt['cmd.run_stdout']('dpkg -s zentyal | grep "^Version" | sed -re "s/Version:.(.+)/\\1/g"', python_shell=True) %}

  {% if not zenyal_version in ['3.2', '3.3'] %}

zentyal_main_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 4.2 main
    - key_url: http://keys.zentyal.org/zentyal-4.2-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer

  {% else %}

    {% if zentyal_version == "3.2" %}
zentyal_main_ubuntu:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/zentyal/3.2/ubuntu {{ grains['lsb_distrib_codename'] }} main
    - humanname: "Zentyal 3.2 series Main"
    - file: /etc/apt/sources.list.d/zentyal-3.2-ppa-{{ grains['lsb_distrib_codename'] }}.list
    - keyid: 0x10E239FF
    - keyserver: keyserver.ubuntu.com
    - require:
      - pkg: ppa_ubuntu_installer
zentyal_extra_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 3.2 extra
    - humanname: "Zentyal 3.2 Extras"
    - file: /etc/apt/sources.list.d/zentyal-3.2-main-extras.list
    - key_url: http://keys.zentyal.org/zentyal-3.2-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - cmd: zentyal_main_ubuntu

    {% elif zentyal_version == "3.3" %}
zentyal_main_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 3.3 main
    - humanname: "Zentyal 3.3 Main"
    - file: /etc/apt/sources.list.d/zentyal-3.3-main.list
    - key_url: http://keys.zentyal.org/zentyal-3.3-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
zentyal_extra_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 3.3 extra
    - humanname: "Zentyal 3.3 Extras"
    - file: /etc/apt/sources.list.d/zentyal-3.3-extras.list
    - key_url: http://keys.zentyal.org/zentyal-3.3-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - cmd: zentyal_main_ubuntu
    {% endif %}
  {% endif % }

{% endif %}
