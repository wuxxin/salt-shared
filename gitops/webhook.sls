{% from "gitops/defaults.jinja" import settings with context %}
{% from "gitops/webhook-lib.sls" import mkhook with context %}

{# install package, but disable and mask default webhook service #}
webhook:
  pkg:
    - installed
  service.dead:
    - enable: false

webhook_masked:
  service.masked:
    - name: webhook

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
      - file: {{ settings.etc_dir }}/webhook.conf

/etc/sudoers.d/webhook-gitops-update:
  file.managed:
    - makedirs: True
    - mode: "0440"
    - contents: |
        {{ settings.user }} ALL=(ALL) NOPASSWD:/bin/systemctl --no-block start gitops-update
    - requires_in:
      - file: {{ settings.etc_dir }}/webhook.conf

/etc/systemd/system/gitops-webhook.service:
  file.managed:
    - source: salt://gitops/gitops-webhook.service
    - template: jinja
    - defaults:
        settings: {{ settings }}
    - requires:
      - file: {{ settings.etc_dir }}/webhook.conf
    - onchanges_in:
      - cmd: systemd_reload


{% if salt['pillar.get']('gitops:webhook:hooks', {}) == {} %}

{{ settings.etc_dir }}/webhook.conf:
  file:
    - absent

gitops-webhook.service:
  service.dead:
    - enable: false
    - require:
      - pkg: webhook
    - watch:
      - file: {{ settings.etc_dir }}/webhook.conf
      - file: /etc/systemd/system/gitops-webhook.service

{% else %}

  {% set ns = namespace(hook_data = []) %}
  {% for hook in settings.hooks %}
    {% load_yaml as new_data %}
{{ mkhook(hook.type, hook.name, hook.secret,
  hook.branch|d('master'), hook.command|d('settings.default_command') }}
    {% endload %}
    {% set new_hook_data = ns.hook_data+ [new_data] %}
    {% set ns.hook_data = new_hook_data %}
  {% endfor %}

{{ settings.etc_dir }}/webhook.conf:
  file.managed:
    - user: {{ settings.user }}
    - group: {{ settings.user }}
    - mode: "0640"
    - contents: |
{{ ns.hook_data|json(True)|indent(8,True) }}

gitops-webhook.service:
  service.running:
    - enable: true
    - require:
      - pkg: webhook
    - watch:
      - file: {{ settings.etc_dir }}/webhook.conf
      - file: /etc/systemd/system/gitops-webhook.service

{% endif %}
