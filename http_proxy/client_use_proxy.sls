{% if salt['pillar.get']('http_proxy', '') != '' %}

{% if salt['grains.get']('os_family') == "Debian" %}
/etc/apt/apt.conf.d/02proxy:
  file.managed:
    - contents: |
        Acquire::http { Proxy "{{ salt['pillar.get']('http_proxy') }}"; };
{% endif %}

{% if salt['file.file_exists']('/etc/default/docker') %}
/etc/default/docker:
  file.replace:
    - pattern: |
        ^#?export http_proxy=.*"
    - repl: |
        export http_proxy="{{ salt['pillar.get']('http_proxy') }}"
    - backup: False
    - append_if_not_found: True
{% endif %}

/etc/profile.d/proxy.sh:
  file.managed:
    - makedirs: True
    - contents: |
        http_proxy="{{ salt['pillar.get']('http_proxy') }}"
        HTTP_PROXY="{{ salt['pillar.get']('http_proxy') }}"
        export http_proxy
        export HTTP_PROXY

/etc/sudoers.d/proxy:
  file.managed:
    - makedirs: True
    - mode: "0440"
    - contents: |
        Defaults env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY"
        Defaults env_keep += "http_proxy https_proxy ftp_proxy no_proxy"

{% endif %}
