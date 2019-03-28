include:
  - tools.qrcode
  - python

{% from "python/init.sls" import pip3_install %}

preseed_pkgs:
  pkg.installed:
    - pkgs:
      - pwgen
      - openssl
      - gnupg
      - whois {# whois needed for mkpasswd #}
      - syslinux
      - genisoimage

{{ pip3_install('jinja2-cli[yaml]') }}