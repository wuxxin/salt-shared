{% if salt['pillar.get']('http_proxy', '') != '' %}

  {% from "http_proxy/defaults.jinja" import default_no_proxy %}

  {% if salt['grains.get']('os_family') == "Debian" %}
/etc/apt/apt.conf.d/02proxy:
  file.managed:
    - contents: |
        Acquire::http { Proxy "{{ salt['pillar.get']('http_proxy') }}"; };
    {%- if salt['pillar.get']('https_proxy', '') != '' %}
        Acquire::https { Proxy "{{ salt['pillar.get']('https_proxy') }}"; };
    {%- endif %}
    - order: 5
  {% endif %}

/etc/profile.d/proxy.sh:
  file.managed:
    - makedirs: True
    - contents: |
        http_proxy="{{ salt['pillar.get']('http_proxy') }}"
        no_proxy="{{ salt['pillar.get']('no_proxy', default_no_proxy) }}"
        export http_proxy
        export no_proxy
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
