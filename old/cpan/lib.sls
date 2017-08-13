# cpan usage
###############

{% macro cpan_check_config(user="root") %}

{% for a in ['CPAN', 'build', 'sources'] %}
cpan_{{ a }}:
  file.directory:
    - name: {{ salt['user.info'](user)['home'] }}/.cpan/{{ a }}
    - makedirs: true
    - require_in:
      - file: cpan_config
{% endfor %}

cpan_config:
  file.managed:
    - name: {{ salt['user.info'](user)['home'] }}/.cpan/CPAN/MyConfig.pm
    - source: salt://cpan/files/MyConfig.pm
    - unless: test -f {{ salt['user.info'](user)['home'] }}/.cpan/CPAN/MyConfig.pm
    - template: jinja
    - makedirs: true
    - context:
      homedir: {{ salt['user.info'](user)['home'] }}

{% endmacro %}


{% macro cpan_install(pkg, user="root") %}

{{ cpan_check_config(user) }}
"cpan_install_{{ pkg }}":
  module.run:
    - name: cpan.install
    - module: {{ pkg }}
    - require:
      - file: cpan_config

{% endmacro %}


{% macro cpan_remove(pkg, user="root") %}

{{ cpan_check_config(user) }}
"cpan_remove_{{ pkg }}":
  module.run:
    - name: cpan.remove
    - module: {{ pkg }}
    - require:
      - file: cpan_config

{% endmacro %}


{% macro cpan_list(user="root") %}

{{ cpan_check_config(user) }}
cpan_list_:
  module.run:
    - name: cpan.list_
    - require:
      - file: cpan_config

{% endmacro %}


{% macro cpan_show(pkg, user="root") %}

{{ cpan_check_config(user) }}
cpan_show_{{ pkg }}:
  module.run:
    - name: cpan.show
    - module: {{ pkg }}
    - require:
      - file: cpan_config

{% endmacro %}


{% macro cpan_show_config(user="root") %}

{{ cpan_check_config(user) }}
cpan_show_config:
  module.run:
    - name: cpan.show_config
    - require:
      - file: cpan_config

{% endmacro %}

