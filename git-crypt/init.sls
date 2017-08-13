include:
  - git
  - openssl
{% if grains['lsb_distrib_codename']  == 'trusty' %}
  - repo.ubuntu

  {% from "repo/ubuntu.sls" import apt_add_repository %}
  {{ apt_add_repository("outsideopen_git_crypt_ppa", "outsideopen/git-crypt") }}

git-crypt:
  pkg.installed:
    - require:
      - pkgrepo: outsideopen_git_crypt_ppa

{% else %}

git-crypt:
  pkg:
    - installed

{% endif %}

