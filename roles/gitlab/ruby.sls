gitlab-ruby:
  pkg.installed:
    - pkgs:
      - ruby2.0
      - ruby2.0-dev

default-ruby-1.9.1:
  cmd.run:
    - name: |
        update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
        --slave /usr/bin/gem gem /usr/bin/gem1.9.1 \
        --slave /usr/bin/ri ri /usr/bin/ri1.9.1 \
        --slave /usr/bin/erb erb /usr/bin/erb1.9.1 \
        --slave /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1 \
        --slave /usr/bin/testrb testrb /usr/bin/testrb1.9.1 \
        --slave /usr/bin/irb irb /usr/bin/irb1.9.1

default-ruby-2.0: 
  cmd.run:
    - name: |
        update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 500 \
        --slave /usr/bin/gem gem /usr/bin/gem2.0 \
        --slave /usr/bin/ri ri /usr/bin/ri2.0 \
        --slave /usr/bin/erb erb /usr/bin/erb2.0 \
        --slave /usr/bin/rdoc rdoc /usr/bin/rdoc2.0 \
        --slave /usr/bin/testrb testrb /usr/bin/testrb2.0 \
        --slave /usr/bin/irb irb /usr/bin/irb2.0

gitlab-update-default-ruby:
  cmd.run:
    - name: update-alternatives --auto ruby
    - require:
      - cmd: default-ruby-1.9.1
      - cmd: default-ruby-2.0
      - pkg: gitlab-ruby

gitlab-bundler:
  pkg.installed:
    - name: bundler
    - require: 
      - cmd: gitlab-update-default-ruby

gitlab-default-ruby:
  cmd.run:
    - name: "echo 'ok, gitlab-default-ruby'"
    - require:
      - pkg: gitlab-bundler

