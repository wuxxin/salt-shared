include:
  - docker
  - appliance
  
rancher-prerequisites:
  pkg.installed:
    - pkgs:
      - jq
      - wget
      - curl
      - httpie

