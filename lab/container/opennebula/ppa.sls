include:
  - repo.ubuntu
  
opennebula_ppa:
  pkgrepo.managed:
    - name: deb http://downloads.opennebula.org/repo/5.2/Ubuntu/16.04 stable opennebula
    - key: salt://opennebula/repo.key
