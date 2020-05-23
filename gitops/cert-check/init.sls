{% from "gitops/defaults.jinja" import settings with context %}

include:
  - gitops.service

gitops-cert-check.sh:
  file.managed:
    - name: /usr/local/bin/gitops-cert-check.sh
    - source: salt://gitops/cert-check/gitops-cert-check.sh
    - mode: "0755"

gitops-cert-check.service:
  file.managed:
    - source: salt://gitops/cert-check/gitops-cert-check.service
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
    - source: salt://gitops/cert-check/gitops-cert-check.timer
    - name: /etc/systemd/system/gitops-cert-check.timer
    - require:
      - file: gitops-cert-check.service
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: gitops-cert-check.timer
  service.running:
    - enabled: true
