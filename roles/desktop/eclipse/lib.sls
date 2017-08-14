{% set inst_app= 'org.eclipse.equinox.p2.director' %}
{% set main_url= 'http://download.eclipse.org/releases/kepler' %}

{% macro keytool_cert(user, name, url, hash) %}
/tmp/{{ name }}-eclipse-cert:
  file.managed:
    - source: {{ url }}
    - source_hash: {{ hash }}
  cmd.run:
    - name: keytool -import -noprompt -file /tmp/{{ name }}-eclipse-cert
    - runas: {{ user }}
    - cwd: {{ user_home }}
    - require:
      - file: /tmp/{{ name }}-eclipse-cert
{% endmacro %}

{% macro eclipse_plugin(user, name, url, group) %}
{{ name }}-eclipse-plugin:
  cmd.run:
    - name: eclipse -nosplash -application {{ inst_app }} -repository {{ main_url }},{{ url }} -installIU {{ group }}
    - runas: {{ user }}
    - cwd: {{ salt['user.info'](user)['home'] }}
{% endmacro %}

