{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu

git-lfs_ppa:
  pkgrepo.managed:
    - name: deb https://packagecloud.io/github/git-lfs/ubuntu/ {{ grains['lsb_distrib_codename'] }} main
    - file: /etc/apt/sources.list.d/git-lfs.list
    - key_url: https://packagecloud.io/gpg.key
  {% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkg: ppa_ubuntu_installer
  {% endif %}      
{% endif %}

git-lfs_nop:
  test:
    - nop
