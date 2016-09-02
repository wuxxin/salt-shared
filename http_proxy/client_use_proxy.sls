{% if salt['pillar.get']('http_proxy', '') != '' %}

  {% if salt['grains.get']('os_family') == "Debian" %}
/etc/apt/apt.conf.d/02proxy:
  file.managed:
    - contents: |
        Acquire::http { Proxy "{{ salt['pillar.get']('http_proxy') }}"; };
    - order: 5
  {% endif %}

  {% if salt['file.file_exists']('/etc/default/docker') %}
    {% for a in ['http_proxy', 'HTTP_PROXY'] %}
docker_{{ a }}:
  file.replace:
    - name: /etc/default/docker
    - pattern: |
        ^#?export {{ a }}=.*"
    - repl: |
        export {{ a }}="{{ salt['pillar.get']('http_proxy') }}"
    - backup: False
    - append_if_not_found: True
    - order: 5
    {% endfor %}
  {% endif %}

/etc/profile.d/proxy.sh:
  file.managed:
    - makedirs: True
    - contents: |
        http_proxy="{{ salt['pillar.get']('http_proxy') }}"
        HTTP_PROXY="{{ salt['pillar.get']('http_proxy') }}"
        export http_proxy
        export HTTP_PROXY
    - order: 5

/etc/sudoers.d/proxy:
  file.managed:
    - makedirs: True
    - mode: "0440"
    - contents: |
        Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY"
        Defaults env_keep += "http_proxy https_proxy ftp_proxy no_proxy"
    - order: 5

{# inactiv

modify_dokku:
  cmd.run:
    - name: dokku config:set --global http_proxy={{ salt['pillar.get']('http_proxy') }} HTTP_PROXY={{ salt['pillar.get']('http_proxy') }}
    - onlyif: which dokku
    - unless: dokku config:get --global http_proxy
#}

{% endif %}
