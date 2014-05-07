{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}

ppa_test_for_precise:
  cmd.run:
    - name: test "precise" = {{ grains['lsb_distrib_codename'] }}

{% if grains['os'] == 'Ubuntu' %}

{% set zentyal_version = salt['cmd.run_stdout']('dpkg -s zentyal | grep "^Version" | sed -re "s/Version:.(.+)/\\1/g"') %}
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
      - cmd: ppa_test_for_precise

zentyal_extra_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 3.2 extra 
    - humanname: "Zentyal 3.2 Extras"
    - file: /etc/apt/sources.list.d/zentyal-3.2-main-extras.list
    - key_url: http://keys.zentyal.org/zentyal-3.2-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
      - cmd: ppa_test_for_precise

{% else %}

add_legacy_zentyal_sources:
  file.append:
    - name: /etc/apt/sources.list
    - text: '#deb http://archive.zentyal.org/zentyal 3.3 main extra'

remove_zentyal_from_main_sources_list:
  file.comment:
    - name: /etc/apt/sources.list
    - regex: 'deb http://archive.zentyal.org/zentyal 3.3 main extra'
    - require:
      - file: add_legacy_zentyal_sources

zentyal_main_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 3.3 main
    - humanname: "Zentyal 3.3 Main"
    - file: /etc/apt/sources.list.d/zentyal-3.3-main.list
    - key_url: http://keys.zentyal.org/zentyal-3.3-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
      - cmd: ppa_test_for_precise
      - file: remove_zentyal_from_main_sources_list

zentyal_extra_ubuntu:
  pkgrepo.managed:
    - name: deb http://archive.zentyal.org/zentyal 3.3 extra
    - humanname: "Zentyal 3.3 Extras"
    - file: /etc/apt/sources.list.d/zentyal-3.3-extras.list
    - key_url: http://keys.zentyal.org/zentyal-3.3-archive.asc
    - require:
      - pkg: ppa_ubuntu_installer
      - cmd: ppa_test_for_precise
      - file: remove_zentyal_from_main_sources_list

{% endif %}
{% endif %}

