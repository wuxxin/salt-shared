
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

rancher-agent-api_wait:
  cmd.run:
    - name: |
        wget --retry-connrefused --tries=30 -q --spider \
             http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }}/v1
    - unless: curl -s --connect-timeout 1 http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }}/v1
    - require:
      - sls: .server

rancher-agent-container:
  cmd.run:
    - name: |
        rancher-agent-registration --url http://{{ settings.net[settings.iface]['inet'][0]['address'] }}:{{ settings.port }} \
        --key KEY --secret SECRET --environment {{ settings.environment }}
    - unless: docker inspect rancher-agent
    - require:
      - cmd: rancher_server_api_wait
      - pip: agent_registration_module

    - name: rancher-agent
    - image: rancher/agent:{{ rancher.agent_tag }}
    - binds:
      - /data/mysql/rancher-server:/var/lib/mysql
    - port_bindings:
      - {{ rahcner.server.ip }}:{{ rancher.server.port }}:8080
    - restart_policy: always
    - require:
      - dockerng: rancher-agent-image
