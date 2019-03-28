{% if grains['osmajorrelease']|int < 18 %}

g810-dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - libhidapi-dev

g810-led:
  git.latest:
    - name: https://github.com/MatMoul/g810-led.git
    - target: /usr/local/src/g810-led
    - require:
      - pkg: g810-dependencies
  cmd.run:
    - name: make bin && make install
    - cwd: /usr/local/src/g810-led
  
{% else %}

g810-led:
  pkg.installed:
    - name: g810-led

{% endif %}