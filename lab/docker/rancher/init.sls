include:
  - python
  - docker
  
rancher-prerequisites:
  pkg.installed:
    - pkgs:
      - jq
      - wget
      - curl

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('rancher-agent-registration') }}

rancher-server-volume:
  docker_volume.present:
    - name: rancher-server-volume
    - driver: local
    
rancher-server-image:
  dockerng.image_present:
    - name: rancher/server:{{ rancher.server.tag }}
    - require:
      - sls: docker

rancher-server.service:
  
  dockerng.running:
    - name: rancher-server
    - image: rancher/server:{{ rancher.server.tag }}
    - binds:
      - /data/mysql/rancher-server:/var/lib/mysql
    - port_bindings:
      - {{ rancher.server.ip }}:{{ rancher.server.port }}:8080
    - restart_policy: always
    - require:
      - dockerng: rancher-server-image

rancher-server-api_wait:
  cmd.run:
    - name: |
        wget --retry-connrefused --tries=30 -q --spider \
             http://{{ rancher.server.ip }}:{{ rancher.server.port }}/v2-beta && sleep 10
    - unless: curl -s --connect-timeout 1 http://{{ rancher.server.ip }}:{{ rancher.server.port }}/v2-beta
    - require:
      - dockerng: rancher-server-container


{% set rancher_environments = salt['pillar.get']('rancher:server:environments') %}

{% if rancher_environments %}
{% for env in rancher_environments %}
{% set rancher_env_name = salt['pillar.get']('rancher:server:environments:' + env + ':name') %}
{% set rancher_env_id = salt['cmd.run']('curl -s "http://' + rancher_ip + ':' + rancher_port|string + '/v2-beta/projectTemplates?name=' + rancher_env_name + '" | jq ".data[0].id"') %}
add_{{ env }}_environment:
  cmd.run:
    - name: |
        curl -s \
             -X POST \
             -H 'Accept: application/json' \
             -H 'Content-Type: application/json' \
             -d '{"name":"{{ rancher_env_name }}", "projectTemplateId":{{ rancher_env_id }}, "allowSystemRole":false, "members":[], "virtualMachine":false, "servicesPortRange":null}' \
             'http://{{ rancher_ip }}:{{ rancher_port }}/v2-beta/projects'
    - unless: |
        curl -s 'http://{{ rancher_ip }}:{{ rancher_port }}/v1/projects' \
             | jq .data[].name \
             | grep -w '{{ rancher_env_name }}'
{% endfor %}
{% endif %}