include:
  - gnupg
  - qrcode

preseed_pkgs:
  pkg.installed:
    - pkgs:
      - pwgen
      - whois {# whois needed for mkpasswd #}


