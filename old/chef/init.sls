include:
  - rvm

chef:
  rvm.gemset_present:
    - ruby: ruby-1.9.3
    - require:
      - rvm: ruby-1.9.3
  pkg.installed:
    - pkgs:
      - zlib1g-dev
      - libssl-dev
      - libreadline6-dev
      - libyaml-dev
    - require:
      - rvm: chef
  gem.installed:
    - ruby: ruby-1.9.3@chef
    - require:
      - pkg: chef

