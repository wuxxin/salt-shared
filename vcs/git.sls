include:
  - vcs.git-crypt
  - vcs.git-filter-repo

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("git-core_ppa",  "git-core/ppa", require_in= "pkg: git") }}

git:
  pkg.installed:
    - pkgs:
      - git
      - git-flow
