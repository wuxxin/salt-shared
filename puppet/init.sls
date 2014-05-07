include:
  - rvm

puppet:
  rvm.gemset_present:
    - ruby: ruby-1.9.3
    - runas: rvm
    - require:
      - rvm: ruby-1.9.3
  pkg.installed:
    - names:
      - zlib1g-dev
      - libssl-dev
      - libreadline6-dev
      - libyaml-dev
    - require:
      - rvm: puppet
  gem.installed:
    - ruby: ruby-1.9.3@puppet
    - runas: rvm
    - require:
      - pkg: puppet
