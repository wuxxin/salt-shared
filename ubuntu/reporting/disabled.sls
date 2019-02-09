apport_masked:
  service.masked:
    - name: apport
    
whoopsie_masked:
  service.masked:
    - name: whoopsie

apport:
  service.dead:
    - enable: false
  pkg:
    - removed
  
whoopsie:
  service.dead:
    - enable: false
  pkg:
    - removed
