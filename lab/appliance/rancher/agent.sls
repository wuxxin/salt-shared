include:
  - docker
  - appliance
  - python
  - .server

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('rancher-agent-registration') }}

rancher-agent-image:
  docker_image.present:
    - name: rancher/agent:{{ settings.agent_tag }}
    - require:
      - sls: docker

      
/etc/systemd/system/rancher-agent.service:
  file.managed:
    - source: salt://lab/appliance/rancher/rancher-agent.service
    - template: jinja
    - context:
      settings: {{ settings }}
    - watch_in:
      - cmd: systemd_reload

rancher-agent.service:
    service.running:
      - enable: true
      - watch:
        - file: /etc/systemd/system/rancher-agent.service

