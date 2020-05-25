{% from "k3s/defaults.jinja" import settings %}
{% set helm_binary='--helm-binary '+ settings.home+ '/.local/share/helm/plugins/helm-x/bin/helm-x' %}

helmfile_apply:
  cmd.run:
    - name: gosu {{ settings.user }} helmfile {{ helm_binary }} apply
    - cwd: {{ settings.state_dir }}
    - require:
      - sls: k3s
