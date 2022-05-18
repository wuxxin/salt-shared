include:
  - vcs.git-crypt
{% if grains['os'] == 'Ubuntu' %}
  - vcs.git-filter-repo

{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("git-core_ppa",  "git-core/ppa", require_in= "pkg: git") }}
{% endif %}

git:
  pkg.installed:
    - pkgs:
      - git
      - git-flow
