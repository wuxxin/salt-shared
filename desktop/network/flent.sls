{# The FLExible Network Tester - make experimental evaluations of networks more reliable and easier #}

include:
  - .iperf2
  - .irtt
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
  
{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip3_install('flent') }}

flent: 
  pkg.installed:
    - pkgs:
      - fping
      - netperf
      - flent
    - require:
      - pkg: iperf2 {# XXX flent needs iperf2 but at least 2.0.8 #}
      - cmd: http-getter
      - pip: python3-flent
  cmd.run:
    - name: make all install
    - cwd: /usr/local/share/doc/flent/misc
    - onchanges:
      - pip: python3-flent
      
