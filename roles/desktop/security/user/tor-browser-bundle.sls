{% from 'roles/desktop/user/lib.sls' import user, user_home, user_download with context %}

{% set bundle_version = '4.0.2' %}
{% set bundle_locale = 'de' %}{# en-US #}
{% set bundle_base = user_home+ '/.local' %}
{% set bundle_root = bundle_base+ '/tor-browser_'+ bundle_locale %}
{% set bits = '64' if grains['osarch'][-2:] == '64' else '32' %}
{% set bundle_name = 'tor-browser-linux'+ bits+ '-'+ bundle_version+ '_'+ bundle_locale+ '.tar.xz' %}
gpg --keyserver x-hkp://pool.sks-keyservers.net --recv-keys 0x416F061063FEE659
gpg --fingerprint 0x416F061063FEE659
Key fingerprint = 8738 A680 B84B 3031 A630  F2DB 416F 0610 63FE E659
gpg --verify tor-browser-2.3.25-13_en-US.exe.asc tor-browser-2.3.25-13_en-US.exe
The output should say "Good signature": 

tor-browser-bundle:
  file.managed:
    - name: {{ user_download }}/{{ bundle_name }}
    - source: https://www.torproject.org/dist/torbrowser/{{ bundle_version }}/{{ bundle_name }}
    - source_hash: https://www.torproject.org/dist/torbrowser/{{ bundle_version }}/{{ bundle_name }}.asc
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
  archive.extracted:
    - source: {{ user_download }}/{{ bundle_name }}
    - name: {{ user_home }}/.local/
    - user: {{ user }}
    - group: {{ user }}
    - archive_format: tar
    - tar_options: J
    - watch:
      - file: tor-browser-bundle

tor-browser-symlink:
  file.symlink:
    - name: {{ user_home }}/bin/tor-browser.sh
    - target: {{ bundle_root }}/start-tor-browser
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
    - require:
      - archive: tor-browser-bundle

tor-bundle-icon:
  file.managed:
    - source: salt://roles/desktop/security/user/icon-TorBrowser.jpg
    - name: {{ bundle_root }}/icon-TorBrowser.jpg
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - archive: tor-browser-bundle

tor-desktop:
  file.managed:
    - source: salt://roles/desktop/security/user/tor.desktop
    - name: {{ user_home }}/.local/share/applications/tor.desktop
    - user: {{ user }}
    - group: {{ user }}
    - template: jinja
    - context:
        execute: {{ user_home }}/bin/tor-browser.sh
        version: {{ bundle_version }}
        icon: {{ bundle_root }}/icon-TorBrowser.jpg
    - makedirs: true
    - require:
      - file: tor-bundle-icon
