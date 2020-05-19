{% from "gitops/defaults.jinja" import settings with context %}

{# webhooks to execute on repository pushes to selected branch
+ gogs_push_this_branch
+ github_push_this_branch
+ gitea_push_this_branch
#}

{%- macro mkhook(hookname, name, secret, branch, command) %}
{%- if hookname == 'gogs_push_this_branch' %}
{{ gogs_push_this_branch(name, secret, branch, command) }}
{%- elif hookname == 'github_push_this_branch' %}
{{ github_push_this_branch(name, secret, branch, command) }}
{%- elif hookname == 'gitea_push_this_branch' %}
{{ gitea_push_this_branch(name, secret, branch, command) }}
{%- endif %}
{%- endmacro %}


{%- macro gogs_push_this_branch(name, secret, branch, command) %}
- id: {{ name }}
  command-working-directory: "{{ settings.home_dir }}"
  execute-command: "{{ command }}"
  pass-arguments-to-command:
    - name: head_commit.id
      source: payload
    - name: pusher.name
      source: payload
    - name: pusher.email
      source: payload
  trigger-rule:
    and:
      - match:
          parameter:
            name: X-Gogs-Signature
            source: header
          secret: "{{ secret }}"
          type: payload-hash-sha256
      - match:
          parameter:
            name: ref
            source: payload
          type: value
          value: refs/heads/{{ branch }}
{%- endmacro %}


{%- macro github_push_this_branch(name, secret, branch, command) %}
- id: {{ name }}
  command-working-directory: "{{ settings.home_dir }}"
  execute-command: "{{ command }}"
  pass-arguments-to-command:
    - name: head_commit.id
      source: payload
    - name: pusher.name
      source: payload
    - name: pusher.email
      source: payload
  trigger-rule:
    and:
      - match:
          parameter:
            name: X-Hub-Signature
            source: header
          secret: "{{ secret }}"
          type: payload-hash-sha1
      - match:
          parameter:
            name: ref
            source: payload
          type: value
          value: refs/heads/{{ branch }}
{%- endmacro %}


{%- macro gitea_push_this_branch(name, secret, branch, command) %}
- id: {{ name }}
  command-working-directory: "{{ settings.home_dir }}"
  execute-command: "{{ command }}"
  pass-arguments-to-command:
    - name: head_commit.id
      source: payload
    - name: pusher.name
      source: payload
    - name: pusher.email
      source: payload
  trigger-rule:
    and:
      - match:
          parameter:
            name: secret
            source: payload
          type: value
          value: "{{ secret }}"
      - match:
          parameter:
            name: ref
            source: payload
          type: value
          value: refs/heads/{{ branch }}
{%- endmacro %}
