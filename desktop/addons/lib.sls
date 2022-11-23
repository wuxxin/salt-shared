{# install addons for user applications #}
{% macro addons_gnomeshell(pkglist) %}
{% endmacro %}

{% macro addons_firefox(pkglist) %}
{% endmacro %}

{% macro addons_chromium(pkglist) %}
{% endmacro %}

{% macro addons_libreoffice(pkgdict) %}
{% endmacro %}

{% macro user_install_oxt(user, identifier, url) %}
  {%- set localfile = user_home+ '/.cache/libreoffice-extensions/'+ identifier+ '.oxt' %}
install_{{ user }}_{{ identifier }}:
  file.managed:
    - source: {{ url }}
    - name: {{ localfile }}
    - user: {{ user }}
    - group: {{ user }}
    - skip_verify: true
    - makedirs: true
  cmd.run:
    - name: unopkg add -s {{ localfile }}
    - runas: {{ user }}
    - cwd: {{ user_home }}
    - unless: unopkg list | grep -q "{{ identifier }}"  #}
    - onchanges:
      - file: install_{{ user }}_{{ identifier }}
    - require:
      - pkg: libreoffice
{% endmacro %}
