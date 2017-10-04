include:
  - gnupg
  - tools.qrcode

preseed_pkgs:
  pkg.installed:
    - pkgs:
      - pwgen
      - whois {# whois needed for mkpasswd #}

iso-env:
  pkg.installed:
    - pkgs:
      - syslinux
      - genisoimage
