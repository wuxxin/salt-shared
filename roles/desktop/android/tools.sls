include:
  - python
{% if grains['os'] == 'Ubuntu' %}
  - repo.ubuntu
{% endif %}

tools:
  pkg.installed:
    - pkgs:
      - android-tools-adb
      - android-tools-adbd
      - android-tools-fastboot

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('git+https://github.com/google/python-adb') }}

{% if grains['lsb_distrib_codename'] == 'trusty' %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("heimdall-ppa", "modycz/heimdall") }}

heimdall:
  pkg.installed:
    - pkgs:
      - heimdall
    - require:
      - cmd: heimdall-ppa
{% endif %}
