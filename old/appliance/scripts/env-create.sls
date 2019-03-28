{% if salt['pillar.get']('extra_env') != "" %}
{% set extra= salt['cmd.run_stdout']('cat '+ pillar.get('extra_env'))|load_yaml %}
{% else %}
{% set extra= {} %}
{% endif %}

{{ salt['pillar.get']('targetfile') }}:
  file.managed:
    - template: jinja
    - source: {{ salt['pillar.get']('template') }}
    - user: {{ salt['pillar.get']('appuser') }}
    - mode: "0600"
    - makedirs: true
    - defaults:
      extra: {{ extra }}
      domain: {{ salt['pillar.get']('domain') }}
