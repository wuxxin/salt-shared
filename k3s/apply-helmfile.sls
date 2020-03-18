{% from "k3s/defaults.jinja" import settings %}
{% set helm_binary='--helm-binary '+ settings.home+ '/bin/helm-x' %}

helmfile_sync:
  cmd.run:
    - runas: {{ settings.user }}
    - name: helmfile {{ helm_binary }} sync
    - cwd: {{ settings.state_dir }}
    - require:
      - sls: k3s
      
helmfile_apply:
  cmd.run:
    - runas: {{ settings.user }}
    - name: helmfile {{ helm_binary }} apply
    - cwd: {{ settings.state_dir }}
    - require:
      - cmd: helmfile_sync
