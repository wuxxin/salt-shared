include:
  - .shellcheck
  - .shfmt

silversearcher-ag: {# command line tool (fast grep) ag #}
  pkg:
    - installed

{% from 'python/lib.sls' import pip3_install %}

black-req:
  pkg.installed:
    - pkgs:
      - python3-appdirs
      - python3-attr {# XXX python package is named attrs not attr #}
      - python3-click
      - python3-toml

{# opinionated python source code formating #}
{{ pip3_install('black', require: 'pkg: black-req') }}
