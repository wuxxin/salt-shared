{# The FLExible Network Tester - make experimental evaluations of networks more reliable and easier #}

include:
  - python
  - desktop.network.iperf2
  - desktop.network.irtt
  - desktop.network.netperf

http-getter:
  pkg.installed:
    - pkgs:
      - build-essential
      - cmake
      - libcurl4-openssl-dev
  git.latest:
    - name: https://github.com/tohojo/http-getter.git
    - target: /usr/local/src/http-getter
    - require:
      - pkg: http-getter
  cmd.run:
    - name: make all install
    - cwd: /usr/local/src/http-getter
    - onchanges:
      - git: http-getter
  
flent-req:
  pkg.installed:
    - pkgs:
      - python3-pyqt5
      - python3-matplotlib
    - require:
      - sls: desktop.network.iperf2
      - sls: desktop.network.irtt
      - sls: desktop.network.netperf
      - cmd: http-getter

{% if grains['os'] == 'Ubuntu' %}

  {% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("flent_ppa", "tohojo/flent", require_in= "pkg: flent") }}

flent: 
  pkg.installed:
    - pkgs:
      - fping
      - flent
    - require:
      - pkg: flent-req

{% else %}

  {% from 'python/lib.sls' import pip3_install %}
{{ pip3_install('git+https://github.com/tohojo/flent.git#egg=flent', require='pkg: flent-req') }}

flent: 
  pkg.installed:
    - pkgs:
      - fping
    - require:
      - pkg: flent-req
      - pip: python3-git+https://github.com/tohojo/flent.git#egg=flent
  cmd.run:
    - name: make all install
    - cwd: /usr/local/share/doc/flent/misc
    - onchanges:
      - pip: python3-git+https://github.com/tohojo/flent.git#egg=flent

{% endif %}
