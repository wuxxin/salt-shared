include:
  - vcs.git
  - openssl
{% if grains['lsb_distrib_codename']  == 'trusty' %}
  - ubuntu

  {% from "ubuntu/init.sls" import apt_add_repository %}
  {{ apt_add_repository("outsideopen_git_crypt_ppa", "outsideopen/git-crypt",
    require_in = "pkg: git-crypt") }}
{% endif %}
  
git-crypt:
  pkg.installed:
    - require:
      - sls: vcs.git
