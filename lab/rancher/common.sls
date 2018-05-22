include:
  - docker
  
rancher-prerequisites:
  pkg.installed:
    - pkgs:
      - jq
      - wget
      - curl
      - httpie
