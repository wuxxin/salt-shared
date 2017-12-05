include:
  - docker

nfs-server-image:
  dockerng.image_present:
    - name: xyz/nfsserver:{{ tag }}
    - require:
      - sls: docker

nfs-server-container:
  dockerng.running:
    - name: nfs-server
    - image: xyz/nfsserver:{{ tag }}
    - cap_add:
      - SYS_ADMIN      
    - environment:
      - CATTLE_DB_CATTLE_PASSWORD: {{ manage_secret('mysql_rancher-server') }}
    - port_bindings:
      - {{ rancher_port }}:8080
    - restart_policy: always
    - require:
      - dockerng: nfs-server-image
