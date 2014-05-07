base:

  'os:Debian':
    - match: grain
    - repo.debian

  'os:Ubuntu':
    - match: grain
    - repo.ubuntu

  'os:(RedHat|CentOS)':
    - match: grain_pcre
    - repo.epel
