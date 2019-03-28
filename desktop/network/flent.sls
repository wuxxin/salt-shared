{# The FLExible Network Tester - make experimental evaluations of networks more reliable and easier #}

include:
  - desktop.network.iperf2
  - desktop.network.irtt
  - python
  
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
      - python3-pyqt4
      - python3-matplotlib

{% from 'python/lib.sls' import pip3_install %}
{{ pip3_install('flent', require='pkg: flent-req') }}

flent: 
  pkg.installed:
    - pkgs:
      - fping
      - netperf
    - require:
      - sls: desktop.network.iperf2 {# XXX flent needs iperf2 but at least 2.0.8 #}
      - sls: desktop.network.irtt
      - cmd: http-getter
      - pip: python3-flent
  cmd.run:
    - name: make all install
    - cwd: /usr/local/share/doc/flent/misc
    - onchanges:
      - pip: python3-flent
      
