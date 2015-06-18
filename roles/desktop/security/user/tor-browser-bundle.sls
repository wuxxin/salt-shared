{% from 'roles/desktop/user/lib.sls' import user, user_home, user_download with context %}

{% set bundle_version = '4.5.1' %}
{% set bundle_locale = 'de' %}{# en-US #}
{% set bundle_base = user_home+ '/.local' %}
{% set bundle_root = bundle_base+ '/tor-browser_'+ bundle_locale %}
{% set bits = '64' if grains['osarch'][-2:] == '64' else '32' %}
{% set bundle_name = 'tor-browser-linux'+ bits+ '-'+ bundle_version+ '_'+ bundle_locale+ '.tar.xz' %}
{% set bundle_signature = bundle_name+ ".asc" %}
{% set bundle_hash = "sha256=7dfcd7df5eb2dec72f475bb80e00e0561578b5cb028faa006a8bf175cbc9fe62" %}

{#
# Verify Download 

https://www.torproject.org/dist/torbrowser/{{ bundle_version }}/{{ signature }}
gpg --keyserver x-hkp://pool.sks-keyservers.net --recv-keys 0x4E2C6E8793298290
gpg --fingerprint 0x4E2C6E8793298290 | grep "Key fingerprint = EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290"
gpg --verify {{ signature }} {{ bundle_name }} | grep "Good signature"
#}

tor-browser-bundle:
  file.managed:
    - name: {{ user_download }}/{{ bundle_name }}
    - source: https://www.torproject.org/dist/torbrowser/{{ bundle_version }}/{{ bundle_name }}
    - source_hash: {{ bundle_hash }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
  archive.extracted:
    - source: {{ user_download }}/{{ bundle_name }}
    - source_hash: {{ bundle_hash }}
    - name: {{ bundle_base }}
    - if_missing: {{ bundle_root }}
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
