{% from "apps/gitops/defaults.jinja" import settings with context %}

include:
  - apps.gitops.service

gitops-cert-check.sh:
  file.managed:
    - name: /usr/local/bin/gitops-cert-check.sh
    - source: salt://app/gitops/cert-check/gitops-cert-check.sh
    - mode: "0755"

gitops-add-cert-check.sh:
  file.managed:
    - name: /usr/local/bin/gitops-add-cert-check.sh
    - source: salt://app/gitops/cert-check/gitops-add-cert-check.sh
    - mode: "0755"

gitops-cert-check.service:
  file.managed:
    - source: salt://app/gitops/cert-check/gitops-cert-check.service
    - name: /etc/systemd/system/gitops-cert-check.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - require:
      - file: gitops-cert-check.sh
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: gitops-cert-check.service

gitops-cert-check.timer:
  file.managed:
    - source: salt://app/gitops/cert-check/gitops-cert-check.timer
    - name: /etc/systemd/system/gitops-cert-check.timer
    - require:
      - cmd: gitops-cert-check.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: gitops-cert-check.timer
  service.running:
    - enable: true
    - require:
      - cmd: gitops-cert-check.timer
