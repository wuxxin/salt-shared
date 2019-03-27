include:
  - .shellcheck
  - .shfmt

silversearcher-ag: {# command line tool (fast grep) ag #}
  pkg:
    - installed

{% from 'python/lib.sls' import pip3_install %}

{{ pip3_install('black') }} {# opinionated python source code formating #}
