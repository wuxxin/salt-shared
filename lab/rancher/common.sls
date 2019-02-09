include:
  - docker
  
rancher-prerequisites:
  pkg.installed:
    - pkgs:
      - jq
      - wget
      - curl
      - httpie

/etc/rancher:
  file.directory:
    - makedirs: True

{#
net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1 
#}
