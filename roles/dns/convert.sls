include:
  - git

{% set tempdir= salt['cmd.run_stdout']('mktemp -d -q') %}
{% set workdir= tempdir+ '/bind-to-tinydns' %}

bind-to-tinydns:
  git.latest:
    - name: https://github.com/derat/bind-to-tinydns.git
    - target: {{ workdir }}
    - require:
      - pkg: git
  cmd.run:
    - cwd: {{ workdir }}
    - name: "make"
    - require:
      - git: bind-to-tinydns
  file.copy:
    - name: {{ workdir }}/bind-to-tinydns
    - target: /usr/local/sbin/bind-to-tinydns
    - require:
      - cmd: bind-to-tinydns

bind-to-tinydns-cleanup:
  file.absent:
    - name: {{ tempdir }}
    - require:
      - file: bind-to-tinydns

# other possibility: https://github.com/jarnix/tinydnstobind.git

tinydns-to-bind:
  file.managed:
    - name: salt://roles/dns/tinydns-to-bind
    - target: /usr/local/sbin/tinydns-to-bind
    - file_mode: 0755


