include:
  - libvirt
  - docker
  - container.nfs
  - container.mysql
  - .ppa

opennebula-node:
  pkg.installed:
    - pkgs:
      - opennebula-node
    - require:
      - sls: .ppa
      - sls: libvirt
      - sls: docker
    
one-master-image:
  dockerng.image_present:
    - name: megamio/docker_onemaster

one-master-server-container:
  dockerng.running:
    - name: one-master
    - image: megamio/docker_onemaster
    - environment:
      - 
    - port_bindings:
      - {{ rancher_port }}:8080
    - restart_policy: always
    - require:
      - dockerng: one-master-image      

one-node-image:
  dockerng.image_present:
    - name: megamio/docker_onenode

one-node-server-container:
  dockerng.running:
    - name: one-node
    - image: megamio/docker_onenode
    - environment:
      - 
    - port_bindings:
      - {{ rancher_port }}:8080
    - restart_policy: always
    - require:
      - dockerng: one-node-image
      - sls: container.nfs      
      