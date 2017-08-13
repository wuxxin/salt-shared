{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

git-lfs_ppa:
  pkgrepo.managed:
    - name: deb https://packagecloud.io/github/git-lfs/ubuntu/ {{ grains['lsb_distrib_codename'] if grains['os'] != 'Mint' else 'trusty' }} main
    - file: /etc/apt/sources.list.d/git-lfs.list
    - key_url: https://packagecloud.io/gpg.key

{% endif %}
