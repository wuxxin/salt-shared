include:
  - vcs.git-crypt
  - vcs.git-filter-repo

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("git-core_ppa",  "git-core/ppa", require_in= "pkg: git") }}
{% endif %}

git:
  pkg.installed:
    - pkgs:
      - git
      - git-flow
