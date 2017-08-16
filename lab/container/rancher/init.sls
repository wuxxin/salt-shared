include:
  - python
  - docker
  
rancher-prerequisites:
  pkg.installed:
    - pkgs:
      - jq
      - wget
      - curl

rancher-server-image:
  dockerng.image_present:
    - name: rancher/server:{{ rancher.server.tag }}
    - require:
      - sls: docker

rancher-server-container:
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


