{# The FLExible Network Tester - make experimental evaluations of networks more reliable and easier #}
{% from 'python/lib.sls' import pip_install %}

include:
  - python
  - desktop.network.iperf2
  - desktop.network.irtt
  - desktop.network.netperf

flent-tools-req:
  pkg.installed:
    - pkgs:
      - build-essential
      - cmake
      - libcurl4-openssl-dev

http-getter:
  git.latest:
    - name: https://github.com/tohojo/http-getter.git
    - target: /usr/local/src/http-getter
    - require:
      - pkg: flent-tools-req
  cmd.run:
    - name: make all install
    - cwd: /usr/local/src/http-getter
    - onchanges:
      - git: http-getter

traffic-gen:
  git.latest:
    - name: https://github.com/tohojo/traffic-gen.git
    - target: /usr/local/src/traffic-gen
    - require:
      - pkg: flent-tools-req
  cmd.run:
    - name: cmake . && make && cp traffic-gen /usr/local/bin
    - cwd: /usr/local/src/traffic-gen
    - onchanges:
      - git: traffic-gen

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
  {%- if grains['osmajorrelease']|int >= 19 %}

    {%- set flent_giturl='https://github.com/tohojo/flent.git@v2.0.0#egg=flent' %}
    {# flent is broken with newer pyqt5,
        git master @2020-01-30 has pyside2 support which is working #}
{{ pip_install('shiboken2', require='pkg: flent-req') }}
{{ pip_install('pyside2', require='pip: shiboken2') }}
{{ pip_install('qtpy', require='pip: pyside2') }}
{{ pip_install('git+'+ flent_giturl, require=['pkg: flent-req', 'pip: qtpy']) }}

flent:
  pkg.installed:
    - pkgs:
      - fping
    - require:
      - pkg: flent-req
      - pip: python3-git+{{ flent_giturl }}
  cmd.run:
    - name: make all install
    - cwd: /usr/local/share/doc/flent/misc
    - onchanges:
      - pip: python3-git+{{ flent_giturl }}

  {%- else %}

{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("flent_ppa", "tohojo/flent", require_in= "pkg: flent") }}

flent:
  pkg.installed:
    - pkgs:
      - fping
      - flent
    - require:
      - pkg: flent-req

  {%- endif %}
{%- endif %}
