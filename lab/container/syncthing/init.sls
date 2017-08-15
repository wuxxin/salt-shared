{% from 'roles/desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - roles.docker

syncthing/syncthing:latest:
  docker_image.present:
    - require:
      - sls: roles.docker

syncthing_container:
  docker_container.running:
    - image: syncthing/syncthing
    - auto_remove: true
    - detach: true
    - restart_policy: unless-stopped
    - port_bindings:
      - 8384:8384
      - 22000:22000
    - environment:
      - UID={{ user_info['uid'] }}
      - GID={{ user_info['gid'] }}
    - binds:
{% for i in pillar.get('syncthing:binds') %}
      - {{ i }}
{% endfor %}

