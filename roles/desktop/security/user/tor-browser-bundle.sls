{% from 'roles/desktop/user/lib.sls' import user, user_home with context %}
https://www.torproject.org/dist/torbrowser/4.0.2/tor-browser-linux64-4.0.2_de.tar.xz.asc
{% set bundle_version = '4.0.2' %}
{% set bundle_locale = 'de' %}{# en-US #}
{% set bundle_base = user_home+ '/.local' %}
{% set bundle_root = bundle_base+ '/tor-browser_'+ bundle_locale %}
{% set bits = '64' if grains['osarch'][-2:] == '64' else '32' %}
{% set bundle_hash = {'32': 'sha1=53c2a4858e3c287c89f91763038634be6ec70ace', '64': 'sha1=5d3d28eab9fc1e79f1f0b0998045a5cbc97ebcf8'} %}
{% set bundle_name = 'tor-browser-linux'+ bits+ '-'+ bundle_version+ '_'+ bundle_locale+ '.tar.xz'

tor-browser-bundle:
  file.managed:
    - name: {{ bundle_base }}/{{ bundle_name }}
    - source: https://www.torproject.org/dist/torbrowser/{{ bundle_version }}/{{ bundle_name }}
    - source_hash: https://www.torproject.org/dist/torbrowser/{{ bundle_version }}/{{ bundle_name }}.asc
    - makedirs: true
  archive.extracted:
    - source: {{ bundle_base }}/{{ bundle_name }}.asc
    - name: {{ user_home }}/.local/
    - if_missing: {{ bundle_root }}
    - user: {{ user }}
    - group: {{ user }}
    - source_hash: {{ bundle_hash[bits] }}
    - archive_format: tar
    - tar_options: J
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
      - file: tor-browser-bundle

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
      - file: tor-browser-bundle
      - file: tor-bundle-icon
