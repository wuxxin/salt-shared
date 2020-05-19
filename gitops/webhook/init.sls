{% from "gitops/defaults.jinja" import settings with context %}
{% from "gitops/webhook/webhook-lib.sls" import mkhook with context %}

include:
  - gitops.service

webhook:
  pkg:
    - installed
  file.managed:
    - name: /etc/systemd/system/webhook.service
    - source: salt://gitops/webhook/webhook.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - requires:
      - pkg: webhook

/usr/local/bin/webhook-gitops-update.sh:
  file.managed:
    - mode: "0755"
    - contents: |
          #!/bin/bash
          set -e
          echo "called as $0 with parameter $@"
          echo "starting gitops-update"
          sudo /bin/systemctl --no-block start gitops-update
    - requires_in:
      - file: /etc/webhook.conf

/etc/sudoers.d/webhook-gitops-update:
  file.managed:
    - makedirs: True
    - mode: "0440"
    - contents: |
        {{ settings.user }} ALL=(ALL) NOPASSWD:/bin/systemctl --no-block start gitops-update
    - requires_in:
      - file: /etc/webhook.conf

{% if salt['pillar.get']('gitops:webhook:hooks', []) == [] %}

/etc/webhook.conf:
  file:
    - absent

webhook.service:
  service.dead:
    - enable: false
    - require:
      - pkg: webhook
      - file: /etc/systemd/system/webhook.service
    - onchanges:
      - file: /etc/webhook.conf
      - file: /etc/systemd/system/webhook.service

{% else %}

  {% set ns = namespace(hook_data = []) %}
  {% for hook in settings.webhook.hooks %}
    {% load_yaml as new_data %}
{{ mkhook(hook.type, hook.name, hook.secret,
  hook.branch|d('master'), hook.command|d('settings.default_command')) }}
    {% endload %}
    {% set new_hook_data = ns.hook_data+ [new_data] %}
    {% set ns.hook_data = new_hook_data %}
  {% endfor %}

/etc/webhook.conf:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0640"
    - contents: |
{{ ns.hook_data|json(True)|indent(8,True) }}

webhook.service:
  service.running:
    - enable: true
    - require:
      - pkg: webhook
      - file: /etc/systemd/system/webhook.service
    - onchanges:
      - file: /etc/webhook.conf
      - file: /etc/systemd/system/webhook.service

{% endif %}
