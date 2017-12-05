# vi: set ft=yaml.jinja :
{% import 'docker/global_vars.jinja' as conf with context %}
{% set rancher_iface = salt['pillar.get']('rancher:server:iface', 'eth0') %}
{% if grains['provider'] == 'VAGRANT' %}
  {% set rancher_iface = 'eth1' %}
{% endif %}
{% set rancher_net = salt['mine.get']('roles:rancher-server','network.interfaces','grain').itervalues().next() %}
{% set rancher_port = salt['pillar.get']('rancher:server:port', 8080) %}
{% set rancher_environment = salt['grains.get']('agentEnvironment', 'Default') %}

rancher-agent-registration:
  pip.installed:
    - name: rancher-agent-registration

rancher-agent-api_wait:
  cmd.run:
    - name: |
        wget --retry-connrefused --tries=30 -q --spider \
             http://{{ rancher_net[rancher_iface]['inet'][0]['address'] }}:{{ rancher_port }}/v1
    - unless: curl -s --connect-timeout 1 http://{{ rancher_net[rancher_iface]['inet'][0]['address'] }}:{{ rancher_port }}/v1

rancher-agent-image:
  dockerng.image_present:
    - name: rancher/agent:{{ rancher.agent.tag }}
    - require:
      - sls: docker

rancher-agent-container:
  cmd.run:
    - name: |
        rancher-agent-registration --url http://{{ rancher_net[rancher_iface]['inet'][0]['address'] }}:{{ rancher_port }} \
                                   --key KEY --secret SECRET --environment {{ rancher_environment }}
    - unless: docker inspect rancher-agent
    - require:
      - cmd: rancher_server_api_wait
      - pip: agent_registration_module
  dockerng.running:
    - name: rancher-agent
    - image: rancher/agent:{{ rancher.agent.tag }}
    - binds:
      - /data/mysql/rancher-server:/var/lib/mysql
    - port_bindings:
      - {{ rahcner.server.ip }}:{{ rancher.server.port }}:8080
    - restart_policy: always
    - require:
      - dockerng: rancher-agent-image
